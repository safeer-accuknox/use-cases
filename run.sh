#!/bin/bash
echo $VERSION > README.md
git add .
git commit -m "$VERSION secret scan test"
git push

