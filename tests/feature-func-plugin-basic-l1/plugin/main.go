// Copyright (c) HashiCorp, Inc.
// SPDX-License-Identifier: BUSL-1.1

package main

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"io"
	"net"
	"net/http"
	"regexp"
	"strings"

	"github.com/hashicorp/terraform-policy-plugin-framework/policy-plugin/plugins"
)

func main() {
	// Original functions (preserved from the upstream sample plugin)
	plugins.RegisterFunction("echo", echo)
	plugins.RegisterFunction("trim", trim)
	plugins.RegisterFunction("http_get", http_get)

	// New functions exercised by tfpolicy-feature-regression
	plugins.RegisterFunction("is_valid_cidr", is_valid_cidr)
	plugins.RegisterFunction("cidr_contains_ip", cidr_contains_ip)
	plugins.RegisterFunction("sha256_hex", sha256_hex)
	plugins.RegisterFunction("is_kebab_case", is_kebab_case)
	plugins.RegisterFunction("count_substring", count_substring)

	plugins.Serve()
}

// ---- Original ---------------------------------------------------------------

func echo(value string) (string, error) {
	return value, nil
}

func trim(value, prefix string) (string, error) {
	return strings.TrimPrefix(value, prefix), nil
}

func http_get(urlPath string) (string, error) {
	resp, err := http.Get(urlPath)
	if err != nil {
		return fmt.Sprintf("{\"message\": {}, \"error\": \"%s\"}", err.Error()), nil
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return fmt.Sprintf("{\"message\": {}, \"error\": \"HTTP status code: %d\"}", resp.StatusCode), nil
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Sprintf("{\"message\": {}, \"error\": \"%s\"}", err.Error()), nil
	}

	return fmt.Sprintf("{\"message\": %s, \"error\": \"\"}", string(body)), nil
}

// ---- New --------------------------------------------------------------------

// is_valid_cidr returns true when the input parses as a valid CIDR block.
func is_valid_cidr(cidr string) (bool, error) {
	_, _, err := net.ParseCIDR(cidr)
	return err == nil, nil
}

// cidr_contains_ip returns true when ip falls inside cidr. Returns an error
// only if cidr itself is malformed; an invalid ip yields false.
func cidr_contains_ip(cidr, ip string) (bool, error) {
	_, network, err := net.ParseCIDR(cidr)
	if err != nil {
		return false, fmt.Errorf("invalid cidr %q: %w", cidr, err)
	}
	parsed := net.ParseIP(ip)
	if parsed == nil {
		return false, nil
	}
	return network.Contains(parsed), nil
}

// sha256_hex returns the lowercase hex SHA-256 digest of s.
func sha256_hex(s string) (string, error) {
	sum := sha256.Sum256([]byte(s))
	return hex.EncodeToString(sum[:]), nil
}

// is_kebab_case returns true when s matches strict kebab-case:
// lowercase letters and digits, separated by single hyphens, no leading or
// trailing hyphen, no consecutive hyphens.
func is_kebab_case(s string) (bool, error) {
	if s == "" {
		return false, nil
	}
	matched, err := regexp.MatchString(`^[a-z0-9]+(-[a-z0-9]+)*$`, s)
	return matched, err
}

// count_substring returns the number of non-overlapping occurrences of needle
// in haystack. Returns 0 for an empty needle (avoids the Go stdlib convention
// of returning len(haystack)+1).
func count_substring(haystack, needle string) (int, error) {
	if needle == "" {
		return 0, nil
	}
	return strings.Count(haystack, needle), nil
}
