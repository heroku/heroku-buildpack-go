package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"strings"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/s3/s3iface"
	"github.com/joeshaw/envdecode"
	"github.com/spf13/cobra"
)

func init() {
	cobra.OnInitialize(loadS3Object)

	Root.PersistentFlags().BoolVarP(&outputShell, "shell", "s", true, "output config vars in shell format")
	Root.PersistentFlags().BoolVarP(&outputJSON, "json", "", false, "output config vars in JSON format")
	Root.AddCommand(configCmd)
	Root.AddCommand(configGetCmd)
	Root.AddCommand(configSetCmd)
	Root.AddCommand(configUnsetCmd)
	Root.AddCommand(runCmd)
}

func main() {
	if err := Root.Execute(); err != nil {
		os.Exit(1)
	}
}

var (
	outputShell bool
	outputJSON  bool
	s3vars      = make(map[string]string)
	cfg         config
	client      s3iface.S3API
)

// Root represents the base command when called without any subcommands
var Root = &cobra.Command{
	Use:   "s3env <command> [FLAGS]",
	Short: "s3env manages config vars and stores them on an s3 object.",
	Long: `s3env wraps an existing command and sets ENV vars for them.

PREREQUISITES
	The following ENV vars are required to use s3env:

        S3ENV_KEY (defaults to env.json)
        S3ENV_BUCKET
        S3ENV_AWS_ACCESS_KEY_ID
        S3ENV_AWS_REGION
		S3ENV_AWS_SECRET_ACCESS_KEY
		
EXAMPLES
        s3env config                  # show all config vars
        s3env config:set FOO=1 BAR=2  # set two vars
        s3env config:get FOO          # display FOO
        s3env config:unset FOO        # remove FOO
        s3env run hello-world         # hello-world will get BAR=2 defined in its ENV

CONTEXT
        One of the limitations of heroku config vars presently is the total
        size you can configure on any given app (32kb). If you're managing
        lots of TLS certificates, that limit quickly runs out.

`,
}

func displayUsage(cmd *cobra.Command) {
	fmt.Fprintln(os.Stderr, "Usage: s3env "+cmd.Use)
	os.Exit(1)
}

func displayErr(err error) {
	fmt.Fprintln(os.Stderr, "s3env: "+err.Error())
	os.Exit(1)
}

func loadS3Object() {
	if err := envdecode.StrictDecode(&cfg); err != nil {
		fmt.Printf("s3env: %s (continuing with empty config)\n", err)
		return
	}

	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(cfg.Region),
		Credentials: credentials.NewStaticCredentials(
			cfg.AccessID,
			cfg.SecretKey,
			"",
		),
	})

	if err != nil {
		fmt.Printf("s3env: aws error: %s\n", err)
		return
	}

	client = s3.New(sess)

	in, err := input()
	if err != nil {
		fmt.Printf("s3env: read input error: %s\n", err)
		return
	}
	defer in.Close()

	if err = json.NewDecoder(in).Decode(&s3vars); err != nil {
		fmt.Printf("s3env: decode input error: %s\n", err)
		return
	}
}

func displayVars(vars map[string]string) {
	if outputJSON {
		enc := json.NewEncoder(os.Stdout)
		enc.Encode(vars)
		return
	}

	for k, v := range vars {
		if strings.Contains(v, "\n") {
			fmt.Printf("%s='%s'\n", k, v)
		} else {
			fmt.Printf("%s=%s\n", k, v)
		}
	}
}

func parseEnvironStrings(environ []string) (map[string]string, error) {
	vars := make(map[string]string)

	for _, v := range environ {
		chunks := strings.SplitN(v, "=", 2)
		if len(chunks) != 2 {
			return nil, fmt.Errorf("Unable to parse %s. Make sure it's of the format KEY=VAL", v)
		}

		vars[chunks[0]] = chunks[1]
	}

	return vars, nil
}

func persistVars() error {
	var buf bytes.Buffer

	if err := json.NewEncoder(&buf).Encode(s3vars); err != nil {
		return fmt.Errorf("encode failed: %s", err)
	}

	_, err := client.PutObject(&s3.PutObjectInput{
		Bucket:               aws.String(cfg.Bucket),
		Key:                  aws.String(cfg.Key),
		Body:                 bytes.NewReader(buf.Bytes()),
		ServerSideEncryption: aws.String(cfg.ServerSideEncryption),
	})

	if err != nil {
		return fmt.Errorf("saving to s3 failed with error: %s", err)
	}
	return nil
}

// input gets the appropriate input source. If there was any data pumped into
// STDIN, we'll choose that. Otherwise we'll try to load the s3 object that
// was configured.
func input() (io.ReadCloser, error) {
	out, err := client.GetObject(&s3.GetObjectInput{
		Bucket: aws.String(cfg.Bucket),
		Key:    aws.String(cfg.Key),
	})
	if err != nil {
		// Cast err to awserr.Error to handle specific error codes.
		aerr, ok := err.(awserr.Error)
		if ok && aerr.Code() == s3.ErrCodeNoSuchKey {
			fmt.Fprintf(os.Stderr, "s3env: object not found. using empty config\n")
			buf := new(bytes.Buffer)
			buf.Write([]byte("{}"))

			return ioutil.NopCloser(buf), nil
		}
		return nil, err
	}
	return out.Body, nil
}
