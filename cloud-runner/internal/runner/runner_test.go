package runner

import (
	"errors"
	"testing"

	"cloud-runner/internal/hcptf"
	"cloud-runner/internal/index"
)

func TestClassifyPlanOutcomeFromPolicyLog(t *testing.T) {
	cases := []struct {
		name      string
		policyLog string
		planStat  string
		want      string
	}{
		{
			name:     "mandatory failed at plan -> FAIL (FB-FLT-002)",
			policyLog: "── Init stage (passed): passed=0 advisory_failed=0 mandatory_failed=0 errored=0 unknown=0\n" +
				"── Plan stage (failed): passed=0 advisory_failed=0 mandatory_failed=1 errored=0 unknown=0\n" +
				"── Apply stage (unreachable): passed=0 advisory_failed=0 mandatory_failed=0 errored=0 unknown=0\n",
			planStat: "policy_soft_failed",
			want:     index.ExpectFail,
		},
		{
			name:     "advisory failed at plan is non-blocking -> PASS (EL-ADV-001)",
			policyLog: "── Apply stage (pending): passed=0 advisory_failed=0 mandatory_failed=0 errored=0 unknown=0\n" +
				"── Init stage (passed): passed=0 advisory_failed=0 mandatory_failed=0 errored=0 unknown=0\n" +
				"── Plan stage (passed): passed=0 advisory_failed=1 mandatory_failed=0 errored=0 unknown=0\n",
			planStat: "applied",
			want:     index.ExpectPass,
		},
		{
			name:     "advisory failed but mandatory passed -> PASS (REG-BIN-009)",
			policyLog: "── Init stage (passed): passed=0 advisory_failed=0 mandatory_failed=0 errored=0 unknown=0\n" +
				"── Plan stage (passed): passed=1 advisory_failed=1 mandatory_failed=0 errored=0 unknown=0\n" +
				"── Apply stage (pending): passed=0 advisory_failed=0 mandatory_failed=0 errored=0 unknown=0\n",
			planStat: "applied",
			want:     index.ExpectPass,
		},
		{
			name:     "unknown at plan -> UNKNOWN (EC-GR-002 / GR-DEP-006 / GR-DEP-008)",
			policyLog: "── Init stage (passed): passed=0 advisory_failed=0 mandatory_failed=0 errored=0 unknown=0\n" +
				"── Plan stage (passed): passed=0 advisory_failed=0 mandatory_failed=0 errored=0 unknown=1\n" +
				"── Apply stage (pending): passed=0 advisory_failed=0 mandatory_failed=0 errored=0 unknown=0\n",
			planStat: "applied",
			want:     index.ExpectUnknown,
		},
		{
			name:      "no policy log -> fall back to run status errored -> FAIL",
			policyLog:  "",
			planStat:   "errored",
			want:       index.ExpectFail,
		},
		{
			name:     "init-stage mandatory failure cancels plan -> FAIL (PP-MOD-002 / REG-BIN-004)",
			policyLog: "── Apply stage (unreachable): passed=0 advisory_failed=0 mandatory_failed=0 errored=0 unknown=0\n" +
				"── Plan stage (canceled): passed=0 advisory_failed=0 mandatory_failed=0 errored=0 unknown=0\n" +
				"── Init stage (failed): passed=0 advisory_failed=0 mandatory_failed=1 errored=0 unknown=0\n",
			planStat: "canceled",
			want:     index.ExpectFail,
		},
		{
			name:     "init passed, plan passed -> PASS (PP-MOD-001)",
			policyLog: "── Init stage (passed): passed=1 advisory_failed=0 mandatory_failed=0 errored=0 unknown=0\n" +
				"── Plan stage (passed): passed=1 advisory_failed=0 mandatory_failed=0 errored=0 unknown=0\n",
			planStat: "planned_and_finished",
			want:     index.ExpectPass,
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			r := &hcptf.RunResult{PolicyLog: tc.policyLog, PlanStatus: tc.planStat}
			if got := classifyPlanOutcome(r); got != tc.want {
				t.Fatalf("classifyPlanOutcome = %q, want %q", got, tc.want)
			}
		})
	}
}

func TestClassifyApplyOutcome(t *testing.T) {
	cases := []struct {
		name        string
		policyLog   string
		planLog     string
		finalStatus string
		want        string
	}{
		{
			name:        "applied cleanly -> PASS (EC-GR-002 / GR-DEP-006 / GR-DEP-008)",
			policyLog:   "── Apply stage (pending): passed=0 advisory_failed=0 mandatory_failed=0 errored=0 unknown=0\n",
			finalStatus: "applied",
			want:        index.ExpectPass,
		},
		{
			name:        "plan blocked apply, run errored -> FAIL (FB-FLT-002)",
			policyLog:   "── Plan stage (failed): passed=0 advisory_failed=0 mandatory_failed=1 errored=0 unknown=0\n",
			finalStatus: "errored",
			want:        index.ExpectFail,
		},
		{
			name:        "apply never confirmed (policy_soft_failed) -> FAIL",
			policyLog:   "",
			finalStatus: "policy_soft_failed",
			want:        index.ExpectFail,
		},
		{
			name:        "zero-change plan, policy passed, planned_and_finished -> PASS (PP-MOD-001)",
			policyLog:   "── Plan stage (passed): passed=1 advisory_failed=0 mandatory_failed=0 errored=0 unknown=0\n",
			planLog:     `{"@message":"Plan: 0 to add, 0 to change, 0 to destroy.","changes":{"add":0,"change":0,"import":0,"remove":0,"operation":"plan"}}`,
			finalStatus: "planned_and_finished",
			want:        index.ExpectPass,
		},
		{
			name:        "planned but never applied (has changes) -> FAIL",
			policyLog:   "── Plan stage (passed): passed=1 advisory_failed=0 mandatory_failed=0 errored=0 unknown=0\n",
			planLog:     `{"@message":"Plan: 3 to add","changes":{"add":3,"change":0,"import":0,"remove":0,"operation":"plan"}}`,
			finalStatus: "planned",
			want:        index.ExpectFail,
		},
		{
			name:        "applied with advisory failure at apply is non-blocking -> PASS",
			policyLog:   "── Apply stage (passed): passed=0 advisory_failed=1 mandatory_failed=0 errored=0 unknown=0\n",
			finalStatus: "applied",
			want:        index.ExpectPass,
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			r := &hcptf.RunResult{PolicyLog: tc.policyLog, PlanLog: tc.planLog, FinalStatus: tc.finalStatus}
			if got := classifyApplyOutcome(r); got != tc.want {
				t.Fatalf("classifyApplyOutcome = %q, want %q", got, tc.want)
			}
		})
	}
}

func TestPolicyStageParsesMixedZeroAndNonZero(t *testing.T) {
	// Given a multi-stage log where init has advisory_failed=0 and plan has
	// advisory_failed=1, when parsing the plan stage, then the non-zero count wins.
	log := "── Init stage (passed): passed=0 advisory_failed=0 mandatory_failed=0 errored=0 unknown=0\n" +
		"── Plan stage (passed): passed=0 advisory_failed=1 mandatory_failed=0 errored=0 unknown=0\n"
	stage := policyStage(log, "plan")
	if !stage.found {
		t.Fatal("plan stage not found")
	}
	if stage.advisoryFailed != 1 {
		t.Fatalf("advisoryFailed = %d, want 1", stage.advisoryFailed)
	}
}

func TestIsNameConflict(t *testing.T) {
	cases := []struct {
		name string
		err  error
		want bool
	}{
		{"TFE cloud phrasing", errors.New("invalid attributes\n\nValidation failed: Name has already been taken"), true},
		{"self-hosted phrasing", errors.New("name is already taken"), true},
		{"already exists phrasing", errors.New("workspace already exists"), true},
		{"unrelated error", errors.New("connection refused"), false},
		{"nil", nil, false},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if got := isNameConflict(tc.err); got != tc.want {
				t.Fatalf("isNameConflict(%v) = %v, want %v", tc.err, got, tc.want)
			}
		})
	}
}
