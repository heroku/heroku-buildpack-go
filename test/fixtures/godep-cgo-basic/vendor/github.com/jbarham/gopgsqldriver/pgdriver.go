// Copyright 2011 John E. Barham. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// Package pgsqldriver is a PostgreSQL driver for the Go SQL database package.
package pgsqldriver

/*
#include <stdlib.h>
#include <libpq-fe.h>

static char**makeCharArray(int size) {
	return calloc(sizeof(char*), size);
}

static void setArrayString(char **a, char *s, int n) {
	a[n] = s;
}

static void freeCharArray(char **a, int size) {
	int i;
	for (i = 0; i < size; i++)
		free(a[i]);
	free(a);
}
*/
// #cgo CFLAGS: -I/usr/include/postgresql
// #cgo LDFLAGS: -L/usr/lib/x86_64-linux-gnu -lpq
import "C"

import (
	"database/sql"
	"database/sql/driver"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"runtime"
	"strconv"
	"strings"
	"time"
	"unsafe"
)

func connError(db *C.PGconn) error {
	return errors.New("conn error:" + C.GoString(C.PQerrorMessage(db)))
}

func resultError(res *C.PGresult) error {
	serr := C.GoString(C.PQresultErrorMessage(res))
	if serr == "" {
		return nil
	}
	return errors.New("result error: " + serr)
}

const timeFormat = "2006-01-02 15:04:05.000000-07"

type Date struct {
	time.Time
}

var _ sql.Scanner = (*Date)(nil)

func (d *Date) Scan(value interface{}) error {
	switch s := value.(type) {
	case string:
		t, err := time.Parse("2006-01-02", s)
		if err != nil {
			return err
		}
		d.Time = t
	default:
		return errors.New("invalid type")
	}
	return nil
}

type postgresDriver struct{}

// Open creates a new database connection using the given connection string.
// Each parameter setting is in the form 'keyword=value'.
// See http://www.postgresql.org/docs/9.0/static/libpq-connect.html#LIBPQ-PQCONNECTDBPARAMS
// for a list of recognized parameters.
func (d *postgresDriver) Open(name string) (conn driver.Conn, err error) {
	cparams := C.CString(name)
	defer C.free(unsafe.Pointer(cparams))
	db := C.PQconnectdb(cparams)
	if C.PQstatus(db) != C.CONNECTION_OK {
		err = connError(db)
		C.PQfinish(db)
		return nil, err
	}
	conn = &driverConn{db, 0}
	runtime.SetFinalizer(conn, (*driverConn).Close)
	return
}

type driverConn struct {
	db      *C.PGconn
	stmtNum int
}

// Check that driverConn implements driver.Execer interface.
var _ driver.Execer = (*driverConn)(nil)

func (c *driverConn) exec(stmt string, args []driver.Value) (cres *C.PGresult) {
	stmtstr := C.CString(stmt)
	defer C.free(unsafe.Pointer(stmtstr))
	if len(args) == 0 {
		cres = C.PQexec(c.db, stmtstr)
	} else {
		cargs := buildCArgs(args)
		defer C.freeCharArray(cargs, C.int(len(args)))
		cres = C.PQexecParams(c.db, stmtstr, C.int(len(args)), nil, cargs, nil, nil, 0)
	}
	return cres
}

func (c *driverConn) Exec(query string, args []driver.Value) (res driver.Result, err error) {
	cres := c.exec(query, args)
	if err = resultError(cres); err != nil {
		C.PQclear(cres)
		return
	}
	defer C.PQclear(cres)
	ns := C.GoString(C.PQcmdTuples(cres))
	if ns == "" {
		return driver.ResultNoRows, nil
	}
	rowsAffected, err := strconv.ParseInt(ns, 10, 64)
	if err != nil {
		return
	}
	return driver.RowsAffected(rowsAffected), nil
}

func (c *driverConn) Prepare(query string) (driver.Stmt, error) {
	// Generate unique statement name.
	stmtname := strconv.Itoa(c.stmtNum)
	cstmtname := C.CString(stmtname)
	c.stmtNum++
	defer C.free(unsafe.Pointer(cstmtname))
	stmtstr := C.CString(query)
	defer C.free(unsafe.Pointer(stmtstr))
	res := C.PQprepare(c.db, cstmtname, stmtstr, 0, nil)
	err := resultError(res)
	if err != nil {
		C.PQclear(res)
		return nil, err
	}
	stmtinfo := C.PQdescribePrepared(c.db, cstmtname)
	err = resultError(stmtinfo)
	if err != nil {
		C.PQclear(stmtinfo)
		return nil, err
	}
	defer C.PQclear(stmtinfo)
	nparams := int(C.PQnparams(stmtinfo))
	statement := &driverStmt{stmtname, c.db, res, nparams}
	runtime.SetFinalizer(statement, (*driverStmt).Close)
	return statement, nil
}

func (c *driverConn) Close() error {
	if c != nil && c.db != nil {
		C.PQfinish(c.db)
		c.db = nil
		runtime.SetFinalizer(c, nil)
	}
	return nil
}

func (c *driverConn) Begin() (driver.Tx, error) {
	if _, err := c.Exec("BEGIN", nil); err != nil {
		return nil, err
	}
	// driverConn implements driver.Tx interface.
	return c, nil
}

func (c *driverConn) Commit() (err error) {
	_, err = c.Exec("COMMIT", nil)
	return
}

func (c *driverConn) Rollback() (err error) {
	_, err = c.Exec("ROLLBACK", nil)
	return
}

type driverStmt struct {
	name    string
	db      *C.PGconn
	res     *C.PGresult
	nparams int
}

func (s *driverStmt) NumInput() int {
	return s.nparams
}

func (s *driverStmt) exec(params []driver.Value) *C.PGresult {
	stmtName := C.CString(s.name)
	defer C.free(unsafe.Pointer(stmtName))
	cparams := buildCArgs(params)
	defer C.freeCharArray(cparams, C.int(len(params)))
	return C.PQexecPrepared(s.db, stmtName, C.int(len(params)), cparams, nil, nil, 0)
}

func (s *driverStmt) Exec(args []driver.Value) (res driver.Result, err error) {
	cres := s.exec(args)
	if err = resultError(cres); err != nil {
		C.PQclear(cres)
		return
	}
	defer C.PQclear(cres)
	rowsAffected, err := strconv.ParseInt(C.GoString(C.PQcmdTuples(cres)), 10, 64)
	if err != nil {
		return
	}
	return driver.RowsAffected(rowsAffected), nil
}

func (s *driverStmt) Query(args []driver.Value) (driver.Rows, error) {
	cres := s.exec(args)
	if err := resultError(cres); err != nil {
		C.PQclear(cres)
		return nil, err
	}
	return newResult(cres), nil
}

func (s *driverStmt) Close() error {
	if s != nil && s.res != nil {
		C.PQclear(s.res)
		runtime.SetFinalizer(s, nil)
	}
	return nil
}

type driverRows struct {
	res     *C.PGresult
	nrows   int
	currRow int
	ncols   int
	cols    []string
}

func newResult(res *C.PGresult) *driverRows {
	ncols := int(C.PQnfields(res))
	nrows := int(C.PQntuples(res))
	result := &driverRows{res: res, nrows: nrows, currRow: -1, ncols: ncols, cols: nil}
	runtime.SetFinalizer(result, (*driverRows).Close)
	return result
}

func (r *driverRows) Columns() []string {
	if r.cols == nil {
		r.cols = make([]string, r.ncols)
		for i := 0; i < r.ncols; i++ {
			r.cols[i] = C.GoString(C.PQfname(r.res, C.int(i)))
		}
	}
	return r.cols
}

func argErr(i int, argType string, err string) error {
	return errors.New(fmt.Sprintf("arg %d as %s: %s", i, argType, err))
}

func (r *driverRows) Next(dest []driver.Value) error {
	r.currRow++
	if r.currRow >= r.nrows {
		return io.EOF
	}

	for i := 0; i < len(dest); i++ {
		if int(C.PQgetisnull(r.res, C.int(r.currRow), C.int(i))) == 1 {
			dest[i] = nil
			continue
		}
		val := C.GoString(C.PQgetvalue(r.res, C.int(r.currRow), C.int(i)))
		switch vtype := uint(C.PQftype(r.res, C.int(i))); vtype {
		case BOOLOID:
			if val == "t" {
				dest[i] = "true"
			} else {
				dest[i] = "false"
			}
		case BYTEAOID:
			if !strings.HasPrefix(val, "\\x") {
				return argErr(i, "[]byte", "invalid byte string format")
			}
			buf, err := hex.DecodeString(val[2:])
			if err != nil {
				return argErr(i, "[]byte", err.Error())
			}
			dest[i] = buf
		case CHAROID, BPCHAROID, VARCHAROID, TEXTOID,
			INT2OID, INT4OID, INT8OID, OIDOID, XIDOID,
			FLOAT8OID, FLOAT4OID,
			DATEOID, TIMEOID, TIMESTAMPOID, TIMESTAMPTZOID, INTERVALOID, TIMETZOID,
			NUMERICOID:
			dest[i] = val
		default:
			return errors.New(fmt.Sprintf("unsupported type oid: %d", vtype))
		}
	}
	return nil
}

func (r *driverRows) Close() error {
	if r.res != nil {
		C.PQclear(r.res)
		r.res = nil
		runtime.SetFinalizer(r, nil)
	}
	return nil
}

func buildCArgs(params []driver.Value) **C.char {
	sparams := make([]string, len(params))
	for i, v := range params {
		var str string
		switch v := v.(type) {
		case []byte:
			str = "\\x" + hex.EncodeToString(v)
		case bool:
			if v {
				str = "t"
			} else {
				str = "f"
			}
		case time.Time:
			str = v.Format(timeFormat)
		default:
			str = fmt.Sprint(v)
		}

		sparams[i] = str
	}
	cparams := C.makeCharArray(C.int(len(sparams)))
	for i, s := range sparams {
		C.setArrayString(cparams, C.CString(s), C.int(i))
	}
	return cparams
}

func init() {
	sql.Register("postgres", &postgresDriver{})
}
