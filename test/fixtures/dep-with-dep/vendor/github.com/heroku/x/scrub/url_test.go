package scrub

import (
	"net/url"
	"strings"
	"testing"
)

func mustParseURL(t *testing.T, val string) (*url.URL, url.Values) {
	u, err := url.Parse(val)
	if err != nil {
		t.Fatal(err)
	}

	return u, u.Query()
}

func TestURL(t *testing.T) {
	for param := range RestrictedParams {
		t.Run(param, func(tt *testing.T) {
			u, q := mustParseURL(tt, "https://thisisnotadoma.in/login")

			q.Set(param, "hunter2")
			u.RawQuery = q.Encode()

			sc := URL(u)
			scq := sc.Query()

			if val := scq.Get(param); val != scrubbedValue {
				tt.Fatalf("%s: want: %q, got: %q", param, scrubbedValue, val)
			}
		})
	}
}

func TestURLUserInfo(t *testing.T) {
	u, _ := mustParseURL(t, "https://AzureDiamond:hunter2@thisisnotadoma.in/login")
	sc := URL(u)

	user := sc.User.Username()
	if user != "AzureDiamond" {
		t.Fatalf("sc.User.Username(): want: \"AzureDiamond\", got: %q", user)
	}

	pass, ok := sc.User.Password()
	if !ok {
		t.Fatalf("expected sc.User.Password to have a value.")
	}

	if pass != scrubbedValue {
		t.Fatalf("sc.User.Password(): want: %q, got: %q", scrubbedValue, pass)
	}
}

func TestURLShouldntScrub(t *testing.T) {
	const (
		param  = "there"
		eValue = "be_dragons"
	)

	u, q := mustParseURL(t, "https://thisisnotadoma.in/login")
	q.Set(param, eValue)
	u.RawQuery = q.Encode()

	sc := URL(u)
	scq := sc.Query()

	if val := scq.Get(param); val != eValue {
		t.Fatalf("%s: want: %q, got: %q", param, eValue, val)
	}
}

func TestURLinURL(t *testing.T) {
	const secret = "hunter2" // http://bash.org/?244321
	for name := range RestrictedParams {
		t.Run(name, func(tt *testing.T) {
			u, q := mustParseURL(t, "https://doesntlooklikestarsto.me/login")
			q.Set(name, secret)
			u.RawQuery = q.Encode()

			ou, oq := mustParseURL(t, "functor://applicative/monad")
			oq.Set("redirect_url", u.String())
			ou.RawQuery = oq.Encode()

			sc := URL(ou)
			if strings.Contains(sc.String(), secret) {
				tt.Fatalf("found parameter that should be scrubbed: input: %q, output: %q", ou.String(), sc.String())
			}
			t.Log(sc.String())
		})
	}
}
