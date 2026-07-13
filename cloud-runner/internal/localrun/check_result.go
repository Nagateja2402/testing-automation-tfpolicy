package localrun

import (
	"fmt"
	"strings"

	"cloud-runner/internal/index"
)

func checkResult(expected string, ec int, output, level string) PhaseResult {
	policyFailed := containsAny(output, "Error: Condition not met", "Warning: Condition not met")
	policyUnknown := containsAny(output, "Warning: Unknown condition", "Unknown condition")

	switch expected {
	case index.ExpectPass:
		return checkPass(ec, output, level, policyFailed, policyUnknown)
	case index.ExpectFail:
		return checkFail(expected, ec, output, level, policyFailed)
	case index.ExpectUnknown:
		return checkUnknown(expected, ec, output, level, policyFailed, policyUnknown)
	case index.ExpectNA:
		return PhaseResult{Expected: expected, Status: "SKIP", Note: "N/A"}
	}

	if strings.HasPrefix(expected, index.ExpectErrorContains) {
		return checkErrorContains(expected, ec, output, level, policyFailed, policyUnknown)
	}
	return PhaseResult{Expected: expected, Status: "ERROR", Note: fmt.Sprintf("unknown expectation value %q", expected)}
}

func checkPass(ec int, output, level string, policyFailed bool, policyUnknown bool) PhaseResult {
	if ec != 0 {
		return PhaseResult{Expected: index.ExpectPass, Status: "FAIL", Note: fmt.Sprintf("%s: exit %d but expected PASS\n%s", level, ec, firstLines(output, 5))}
	}
	if policyFailed {
		return PhaseResult{Expected: index.ExpectPass, Status: "FAIL", Note: fmt.Sprintf("%s: policy condition not met (expected PASS)\n%s", level, firstLines(output, 5))}
	}
	if policyUnknown {
		return PhaseResult{Expected: index.ExpectPass, Status: "FAIL", Note: fmt.Sprintf("%s: policy condition unknown (expected definitive PASS)\n%s", level, firstLines(output, 5))}
	}
	return PhaseResult{Expected: index.ExpectPass, Status: "PASS"}
}

func checkFail(expected string, ec int, output, level string, policyFailed bool) PhaseResult {
	if ec != 0 {
		return PhaseResult{Expected: expected, Status: "PASS", Note: fmt.Sprintf("exit %d (expected failure)", ec)}
	}
	if policyFailed {
		return PhaseResult{Expected: expected, Status: "PASS", Note: "policy condition not met (expected failure)"}
	}
	return PhaseResult{Expected: expected, Status: "FAIL", Note: fmt.Sprintf("%s: exit 0, no policy failure detected (expected FAIL)\n%s", level, firstLines(output, 5))}
}

func checkUnknown(expected string, ec int, output, level string, policyFailed bool, policyUnknown bool) PhaseResult {
	if ec != 0 {
		return PhaseResult{Expected: expected, Status: "FAIL", Note: fmt.Sprintf("%s: exit %d but expected UNKNOWN (exit 0 + warning)\n%s", level, ec, firstLines(output, 5))}
	}
	if policyUnknown {
		return PhaseResult{Expected: expected, Status: "PASS", Note: "policy condition unknown (expected)"}
	}
	if policyFailed {
		return PhaseResult{Expected: expected, Status: "FAIL", Note: fmt.Sprintf("%s: policy failed (expected UNKNOWN, not definitive FAIL)\n%s", level, firstLines(output, 5))}
	}
	return PhaseResult{Expected: expected, Status: "PASS", Note: "exit 0 with no unknown warning (condition may have resolved at plan time)"}
}

func checkErrorContains(expected string, ec int, output, level string, policyFailed bool, policyUnknown bool) PhaseResult {
	substr := strings.TrimSpace(strings.TrimPrefix(expected, index.ExpectErrorContains))
	if strings.Contains(output, substr) && (ec != 0 || policyFailed || policyUnknown) {
		return PhaseResult{Expected: expected, Status: "PASS", Note: fmt.Sprintf("exit %d, output contains %q", ec, substr)}
	}
	if ec == 0 && strings.Contains(output, substr) {
		return PhaseResult{Expected: expected, Status: "PASS", Note: fmt.Sprintf("output contains %q", substr)}
	}
	return PhaseResult{Expected: expected, Status: "FAIL", Note: fmt.Sprintf("%s: exit=%d expected error containing %q\n%s", level, ec, substr, firstLines(output, 5))}
}

func firstLines(s string, n int) string {
	lines := strings.SplitN(s, "\n", n+1)
	if len(lines) > n {
		lines = lines[:n]
	}
	return strings.Join(lines, "\n")
}

func containsAny(s string, subs ...string) bool {
	sl := strings.ToLower(s)
	for _, sub := range subs {
		if strings.Contains(sl, strings.ToLower(sub)) {
			return true
		}
	}
	return false
}
