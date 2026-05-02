---
name: Fetch aqua Document
description: Fetch the document of aqua from the other repository aquaproj/aqua. This skill is useful when you want to know the specification of aqua.
---

The document of aqua is hosted at https://github.com/aquaproj/aqua.
So please checkout the repository and refer the document.

```sh
mkdir -p .ai
if [ ! -d .ai/aqua ]; Then
  git clone https://github.com/aquaproj/aqua .ai/aqua
fi
cd .ai/aqua
git pull origin main
```

Then please see .ai/aqua/website/docs.
Especially, about the registry settings, please see .ai/aqua/website/docs/reference/registry-config/\*.md.
