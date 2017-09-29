package main

import (
	"fmt"
	"strings"

	"github.com/spf13/cobra"
)

// config is used in production when you want to fetch a JSON config
// from an S3 object.
type config struct {
	Key    string `env:"S3ENV_KEY,default=env.json"`
	Bucket string `env:"S3ENV_BUCKET,required"`

	AccessID  string `env:"S3ENV_AWS_ACCESS_KEY_ID,required"`
	Region    string `env:"S3ENV_AWS_REGION,required"`
	SecretKey string `env:"S3ENV_AWS_SECRET_ACCESS_KEY,required"`

	ServerSideEncryption string `env:"S3ENV_AWS_SERVER_SIDE_ENCRYPTION,default=AES256"`
}

var configUnsetCmd = &cobra.Command{
	Use:   "config:unset KEY1 [KEY2]...",
	Short: "unset one or more config vars",
	Long:  "config:unset unsets one or more config vars",
	Run: func(cmd *cobra.Command, args []string) {
		if len(args) == 0 {
			displayUsage(cmd)
		}

		for _, key := range args {
			delete(s3vars, key)
		}

		fmt.Printf("Unsetting %s... ", strings.Join(args, ", "))
		if err := persistVars(); err != nil {
			displayErr(err)
		}
		fmt.Println("done!")
	},
}

var configCmd = &cobra.Command{
	Use:   "config",
	Short: "display all config vars",
	Long:  "config fetches all the config vars and displays them in the desired format",
	Run: func(cmd *cobra.Command, args []string) {
		displayVars(s3vars)
	},
}

var configSetCmd = &cobra.Command{
	Use:   "config:set KEY1=VAL1 KEY2=VAL2",
	Short: "set one or more config vars",
	Long:  "config:set sets one or more config vars",
	Run: func(cmd *cobra.Command, args []string) {
		if len(args) == 0 {
			displayUsage(cmd)
		}

		vars, err := parseEnvironStrings(args)
		if err != nil {
			displayErr(err)
		}

		var keys []string
		for k, v := range vars {
			keys = append(keys, k)
			s3vars[k] = v
		}

		fmt.Printf("Setting %s... ", strings.Join(keys, ", "))
		if err := persistVars(); err != nil {
			displayErr(err)
		}
		fmt.Println("done!")
		displayVars(vars)
	},
}

var configGetCmd = &cobra.Command{
	Use:   "config:get KEY",
	Short: "display a config value",
	Long:  "config:get fetches the value of a single KEY.",
	Run: func(cmd *cobra.Command, args []string) {
		if len(args) != 1 {
			displayUsage(cmd)
		}
		fmt.Println(s3vars[args[0]])
	},
}
