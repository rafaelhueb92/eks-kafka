# Postmortem: Argo CD Application not created — orphaned `argocd-applications` Helm release

**Date:** 2026-08-29
**Component:** Argo CD bootstrap (`helm_release.argocd_applications`)
**Severity:** Medium (blocked app creation, no data loss)

## Summary

The `kafka` Argo CD `Application` was not being created on the cluster. `terraform apply`
failed with `cannot re-use a name that is still in use` when creating the
`argocd-applications` Helm release that renders the Application manifest.

## Root cause

A previous `argocd-applications` Helm release existed in the `argocd` namespace in a
`failed` status, but it was **not tracked in the Terraform state**. The release was created
at 14:16 (an earlier attempt), while the state only contained the `argocd` release.

Because Helm does not allow two releases with the same name in the same namespace, the
`helm_release` resource could not create a new release with the name `argocd-applications`,
and Terraform could not manage the orphaned one (it was not in state).

## Timeline

1. `terraform apply` → `Error: installation failed ... cannot re-use a name that is still in use`
2. `helm list -n argocd` → showed `argocd-applications` in `failed` status, revision 1
3. Confirmed the release was not present in `terraform.tfstate` (only `argocd` was tracked)
4. Removed the orphaned release with `helm uninstall argocd-applications -n argocd`
5. Re-ran `terraform apply` → release created successfully, `kafka` Application appeared

## Resolution

```bash
helm uninstall argocd-applications -n argocd
terraform apply -auto-approve
```

After uninstalling the orphaned release, Terraform was able to create the
`argocd-applications` release and the `kafka` Application was rendered and applied.

## Prevention

- If a Helm release is created outside of Terraform (or a previous apply fails mid-way),
  it can be left orphaned and block future applies. Check for untracked releases before
  re-applying:
  ```bash
  helm list -A
  ```
- Prefer `terraform state rm` / `terraform import` over manual `helm uninstall` when the
  release is meant to be managed by Terraform, so state and cluster stay in sync.

## Follow-ups

- The `kafka` Application now syncs, but the sync is blocked because the Strimzi operator
  (`kafka.strimzi.io` CRDs) is not installed on the cluster. Installing the operator is
  required for the sync to complete.
