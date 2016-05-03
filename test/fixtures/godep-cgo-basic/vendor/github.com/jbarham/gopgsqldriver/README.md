pgsqldriver
===========

pgsqldriver is a PostgreSQL driver for the [Go SQL database package]
(http://weekly.golang.org/pkg/database/sql/).

Installation
------------

	go get github.com/jbarham/gopgsqldriver

By default the package is configured to build on Linux.

Usage
-----

	import "database/sql"
	import _ "github.com/jbarham/gopgsqldriver"
		
Note that by design pgsqldriver is not intended to be used directly.
You do need to import it for the side-effect of registering itself with
the sql package (using the name "postgres") but thereafter all interaction
is via the sql package API.  See the included test file pgsqldriver_test.go
for example usage.

About
-----

pgsqldriver is based on my [pgsql.go package](https://github.com/jbarham/pgsql.go).

John Barham 
jbarham@gmail.com 
[@john_e_barham](http://www.twitter.com/john_e_barham) 
Melbourne, Australia
