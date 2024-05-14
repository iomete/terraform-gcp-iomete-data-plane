# Publish new release

https://registry.terraform.io/modules/iomete/iomete-data-plane/gcp/latest

Let's say the new version is `1.1.2`.

## Step 1: Update the version number

Update the version number in the `main.tf` file. See the line something like this:

```hcl
module_version        = "1.1.0"
```

and commit&push the changes as `Update version to 1.1.2`.

## Step 2: Create tag

Create a new tag with the version number:

```shell
git tag v1.1.2
git push origin v1.1.2
```

