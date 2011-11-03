This quickstart will get you going with [Go](http://golang.org/) on Heroku's
[Cedar](http://devcenter.heroku.com/articles/cedar) stack.

## Prerequisites

* Basic knowledge of Go, including command `goinstall` and package `http`.
* Your application must run on [Go release.r60](http://golang.org/doc/devel/release.html).
* Your application must build using standard [goinstall directory structure](http://golang.org/cmd/goinstall/).
* A Heroku user account.  [Signup is free and instant.](https://api.heroku.com/signup)

## Local Workstation Setup

We'll start by setting up your local workstation with the Heroku command-line client and the Git revision control system; and then logging into Heroku to upload your `ssh` public key.  If you've used Heroku before and already have a working local setup, skip to the next section.

<table>
  <tr>
    <th>If you have...</th>
    <th>Install with...</th>
  </tr>
  <tr>
    <td>Mac OS X</td>
    <td style="text-align: left"><a href="http://toolbelt.herokuapp.com/osx/download">Download OS X package</a></td>
  </tr>
  <tr>
    <td>Windows</td>
    <td style="text-align: left"><a href="http://toolbelt.herokuapp.com/windows/download">Download Windows .exe installer</a></td>
  </tr>
  <tr>
    <td>Ubuntu Linux</td>
    <td style="text-align: left"><a href="http://toolbelt.herokuapp.com/linux/readme"><code>apt-get</code> repository</a></td>
  </tr>
  <tr>
    <td>Other</td>
    <td style="text-align: left"><a href="http://assets.heroku.com/heroku-client/heroku-client.tgz">Tarball</a> (add contents to your <code>PATH</code>)</td>
  </tr>
</table>

Once installed, you'll have access to the `heroku` command from your command shell.  Log in using the email address and password you used when creating your Heroku account:

    $ heroku login
    Enter your Heroku credentials.
    Email: adam@example.com
    Password: 
    Could not find an existing public key.
    Would you like to generate one? [Yn] 
    Generating new SSH public key.
    Uploading ssh public key /Users/adam/.ssh/id_rsa.pub

Press enter at the prompt to upload your existing `ssh` key
or create a new one, used for pushing code later on.

## Installing Go

It's best to install Go directly from source code, rather than using
homebrew, apt, or another packaging system.

If you already have Go release.r60 installed, feel free to skip this section.

These commands will download the Go source and build the compiler
and related tools:

    $ GOROOT=$HOME/src/go # adjust this path as you wish
    $ hg clone -r release.r60 https://go.googlecode.com/hg/ $GOROOT
    $ cd $GOROOT/src
    $ ./all.bash

Now put the value of `$GOROOT/bin` in your path, and you're set.

For more details, the Go web site has
[full instructions for installing Go](http://golang.org/doc/install.html).

## Write Your Application

You may be starting with an existing Go application. If not,
here’s a simple "hello, world" application you can use:

### src/hello/app.go

    package main

    import (
        "fmt"
        "http"
        "github.com/kr/pretty.go"
        "log"
        "os"
    )

    func main() {
        http.Handle("/", http.HandlerFunc(hello))
        err := http.ListenAndServe(":"+os.Getenv("PORT"), nil)
        if err != nil {
            log.Fatal("ListenAndServe:", err)
        }
    }

    func hello(w http.ResponseWriter, req *http.Request) {
        fmt.Fprintln(w, "hello, world!")
        pretty.Fprintf(w, "%# v", struct{X int}{3})
    }

## Build your App and its Dependencies

Cedar recognizes Go apps by the existence of a `.go` source file
in the `src` directory (or any of its subdirectories).

Your app and its dependencies are built all together by `goinstall`.
For example, the code above uses package
[pretty.go](https://github.com/kr/pretty.go), which will be downloaded
and built automatically.

Create a new empty directory where you want to have goinstall put
the source code and object files of remote packages. It can go
anywhere you like; for this example we'll use `~/inst`.

    $ mkdir -p ~/inst

Now build your app using `goinstall`:

    $ GOPATH=~/inst:`pwd` goinstall hello

Prevent build artifacts from going into revision control by creating
this file:

### .gitignore

    *.[568]
    bin
    src/hello/hello

## Declare Process Types With Foreman and Procfile

To run your web process, you need to declare what command to use.
In this case, we simply need to execute our Go program. We’ll use
`Procfile` to declare how our web process type is run.

Here's a `Procfile` for the sample app we've been working on:

    web: bin/hello

Now that you have a `Procfile`, you can start your application with [Foreman](http://blog.daviddollar.org/2011/05/06/introducing-foreman.html):

    $ foreman start
    13:58:29     web.1  | started with pid 5997

Your app will come up on port 5000. Test that it's working with `curl`
or a web browser, then Ctrl-C to exit.

## Store Your App in Git

We now have the three major components of our app: application source in `src/hello/app.go`, process types in `Procfile`, and dependencies as specified in the source code. Let's put it into Git:

    $ git init
    $ git add .
    $ git commit -m init

## Deploy to Heroku/Cedar

Create the app on the Cedar stack:

    $ heroku create --stack cedar
    Creating pure-sunrise-3607... done, stack is cedar
    http://pure-sunrise-3607.herokuapp.com/ | git@heroku.com:pure-sunrise-3607.git
    Git remote heroku added

Configure the Go buildpack:

    $ heroku config:add BUILDPACK_URL=git@github.com:heroku/buildpack-go.git

Deploy your code:

    $ git push heroku master
    Counting objects: 6, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (5/5), done.
    Writing objects: 100% (6/6), 687 bytes, done.
    Total 6 (delta 0), reused 0 (delta 0)

    -----> Heroku receiving push
    -----> Go app detected
    -----> Using Go version release.r60.2
    -----> Go version release.r60.2 cached; Skipping clone
    -----> Go version release.r60.2 build; Skipping build
    -----> Running goinstall
    -----> Discovering process types
           Procfile declares types -> web
    -----> Compiled slug size is 912K
    -----> Launching... done, v1
           http://pure-sunrise-3607.herokuapp.com deployed to Heroku

    To git@heroku.com:pure-sunrise-3607.git
     * [new branch]      master -> master    

Now, let's check the state of the app's processes:

    $ heroku ps
    UPID      Process       State               Command
    --------  ------------  ------------------  ------------------------------
    19237303  web.1         up for 11m          bin/hello

The web process is up. Review the logs for more information:

    $ heroku logs
    [put example logs here]

Looks good. We can now visit the app with `heroku open`.

## Running a Worker

The `Procfile` format lets you run any number of different [process types](procfile).  For example, let's say you wanted a worker process to complement your web process. Just add another directory containing the source code for your worker command, `src/work/work.go`, and build as usual with `goinstall`:

    $ GOPATH=~/inst:`pwd` goinstall work

#### Procfile

    web: bin/hello
    worker: bin/work

(Running more than one dyno for an extended period may incur charges to your account.
Read more about [dyno-hour costs](http://devcenter.heroku.com/articles/how-much-does-a-dyno-cost).)

Push this change to Heroku, then launch a worker:

    $ heroku scale worker=1
    Scaling worker processes... done, now running 1

Check `heroku ps` to see that your worker comes up, and `heroku logs` to see your worker doing its work.

