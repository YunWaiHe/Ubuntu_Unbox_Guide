## Github验证

### 方法1 (推荐)

使用 [git-credential-manager](https://github.com/git-ecosystem/git-credential-manager)

[官网安装教程](https://github.com/git-ecosystem/git-credential-manager/blob/release/docs/install.md)

```shell
# for Debian based OS
# https://github.com/GitCredentialManager/git-credential-manager/releases/latest
sudo dpkg -i gcm-manager-xxx.deb
# indicate --no-ui to avoid font problem
# global config
git config --global credential.helper "/usr/local/bin/git-credential-manager --no-ui"
git config --global credential.credentialStore secretservice # export GCM_CREDENTIAL_STORE=secretservice

# 不同项目下可能使用不同的用户名
cd yourproject
git config credential.username yourname
```

### 方法2

```shell
sudo apt install seahorse libsecret-1-0 libsecret-1-dev libsecret-tools
cd /usr/share/doc/git/contrib/credential/libsecret
sudo make
git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
```



参考：

[^1]:https://windperson.wordpress.com/2022/08/29/1097/
[^2]:https://blog.djnavarro.net/posts/2021-08-08_git-credential-helpers/#use-libsecret-credential-manager
[^3]:https://stackoverflow.com/questions/67405245/how-to-store-multiple-pats-passwords-for-use-by-git







