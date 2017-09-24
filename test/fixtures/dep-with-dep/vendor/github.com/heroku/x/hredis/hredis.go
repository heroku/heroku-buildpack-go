package hredis

import (
	"errors"
	"net"
	"net/url"
	"strconv"
)

// RedissURL (rediss://) from an insecure redis:// url. Meant to be used as
// RedissURL(os.Getenv("REDIS_URL")). This eliminates the need for the
// heroku-redis-buildpack (https://github.com/heroku/heroku-buildpack-redis) for
// premium-* plans. Does not work with hobby-dev plans.
func RedissURL(s string) (string, error) {
	u, err := url.Parse(s)
	if err != nil {
		return "", err
	}
	switch u.Scheme {
	case "redis": // NOOP
	case "rediss":
		return s, nil
	default:
		return "", errors.New("invalid scheme " + u.Scheme)
	}
	h, p, err := net.SplitHostPort(u.Host)
	if err != nil {
		return "", err
	}
	if p == "" {
		return "", errors.New("missing port")
	}
	port, err := strconv.Atoi(p)
	if err != nil {
		return "", err
	}
	port++
	u.Scheme = "rediss"

	u.Host = net.JoinHostPort(h, strconv.Itoa(port))
	return u.String(), nil
}
