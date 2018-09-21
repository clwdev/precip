![precip](precip-logo-thin.png)

# Precip: Local Development for Cloud-y Drupal
**Precip** is a [Vagrant](http://www.vagrantup.com)-based all-inclusive local development environment for building Drupal Sites you'll eventually be pushing up to one of several wonderful Drupal Cloud Hosting Services. It's initially being built against Acquia Cloud, but may eventually support other similar services.

## What's Included?
A full LAMP stack, and a few nice extras.
- Ubuntu Server 16.04.3 LTS
- Apache Server 2.4
- MariaDB 10.1
- PHP 5.6, 7.0, 7.1 and 7.2
  - With Memcache, OPCache, and Xdebug all pre-configured
- MailHog, the _absolute_ simplest way to locally test mail delivery

## Why not build your own box from scratch?
**Precip** offers a few key benefits over rolling your own completely custom Vagrant setup that may not be _immediately_ apparent from staring at a freshly `vagrant init`'ed box.
- **One box for many sites** - It's common to see people build single-purpose Vagrant boxes for individual sites or projects. That's cool, but if you're managing a bunch of Drupal sites on a Cloud host, your environments are (hopefully) going to be identical, so why bother juggling VM's or have your system get bogged down by trying to run six LAMP servers simultaneously? You can use this one box to host an arbitrary number of sites.
- **Simple Virtualhost Configuration** - Our [config.rb](config.rb-dist) lets you easily set up a bunch of Apache Virtualhosts without having to hack on the Vagrantfile, Puppet, or the live box itself. It also has friendly config options to tweak bits of your Drupal environment, like setting multi-site directories, domain aliases and so on.
- **All data lives outside of the box** - Your actual project repos, MySQL data directories and log files all live outside of the Vagrant box and will survive both the box being reprovisioned *and* completely being blown out and rebuilt from scratch. Getting this to work in a sane way required us to write a [Vagrant plugin](https://github.com/jeffgeorge/vagrant-useradd), so I doubt you'll find another Vagrant box that does this.
- **Easily Extensible** - Figuring out your base Puppet config to get a functional server can be daunting. Here it's mostly done. Want to add an extra PHP module or something? It's probably one line and easily testable, versus having to Puppet-ize your entire environment first.

# Getting Started with Precip

## Pre-flight Checklist
- Get [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- Get [Vagrant](http://www.vagrantup.com/downloads.html)
  - Note: Precip now requires Vagrant <= 2.1.3, due to how Vagrant Plugins are managed

## Git Clones & Configuration
- Clone this repo
- Clone all your various project repos under the .gitignored `/sites` directory
  - Note: These don't all _have_ to be Drupal Sites. Nearly any PHP site that just needs a vhost + database should be fine.
- Edit `/config.rb-dist`, fill in the blanks, and save it as `/config.rb`

### A Quick Note About PHP Versions

PHP 5.6 and 7.0 are slated to be EOL'ed in 2018, so you should _really_ be testing stuff vs 7.1 or 7.2 as soon as possible. Precip is here to help. We use [`php-fpm`](https://php-fpm.org/) instead of `mod-php`, which allows us to have PHP 5.6, 7.0, 7.1 and 7.2 running on the same box concurrently.

By default new docroots defined in `config.rb` now use 7.1, but if you want to switch back to 5.6 or whatever, you just have to add a `php_version` parameter:

```
drupal_sites = {
  "test-site" => {
    "host" => "test.vm",
    "path" => "test-site/docroot",
    "php_version" => "5.6",
  },
```

We also have four default hostnames so you can quickly check how the various versions of PHP are configured:

 - [56.precip.vm](http://56.precip.vm)
 - [70.precip.vm](http://70.precip.vm)
 - [71.precip.vm](http://71.precip.vm)
 - [72.precip.vm](http://72.precip.vm)

## Downloading, Booting & Provisioning the Vagrant Box
- Kick off Vagrant by running `$ vagrant up`
  - Note: If you don't have various vagrant plugins installed Precip will install them for you, but you'll have to re-run `vagrant up` when it's done.
  - **Warning:** This will probably take geologic age the first time, since Vagrant first has to download the ~200Mb base box. It's a one-time thing, though.
- Once Vagrant downloads the base box it will hand off to Puppet for provisioning
- Once Puppet is finished provisioning your environment will be ready to use!

## Updating Vagrant
- If you do a `$ git pull` and see that the `Vagrantfile` has been updated, you may want to make sure things are up to date by running `$ vagrant reload --provision`.
- If things ever get weird for whatever reason, you can always completely nuke and rebuild the box with `$ vagrant destroy -f && vagrant up`.
- Don't be afraid of doing that. It's not destructive to your data, and only takes about 7 minutes.

# Actually Using Precip
So you've got your Clones and you've got Vagrant running. That means all your hosts are up on whatever local domains you defined in `config.rb`. Next Steps?

## Install Drush Aliases
Upon completing the provisioning process we build a convenient [Drush Aliases file](https://github.com/drush-ops/drush/blob/6.x/examples/example.aliases.drushrc.php) for you in the .gitignored `vm.aliases.drushrc.php` file. You can install these aliases by running `install_aliases.sh`. Once installed you can access any of your sites from anywhere on your local machine by using one of the `@vm.[sitename]` aliases. So, for instance: `$ drush @vm.testsite status` would give you a status report for the site "testsite".

Drush isn't (presently) installed inside the box, which is actually preferable. Drush 6.x doesn't work with "remote" hosts on local IP's (it's a [known oversight](https://github.com/drush-ops/drush/pull/546) and is only implemented in Drush 7.x). Other fun tools like [drush_sql_sync_pipe](https://www.drupal.org/project/drush_sql_sync_pipe) [don't support Drush 7 yet](https://www.drupal.org/node/2406661), and other things like *normal* sql-sync don't work if both aliases are considered "remotes". It'd be awesome to set up aliases that would let you interact with your local Vagrant the exact same way as your remote cloud environments, but right now it sadly isn't ready for prime-time.

## Importing Databases
- You've got a database server running on `precip.vm`, and can connect with user/pass `precip` / `precip`
- Connect with [SequelPro](http://www.sequelpro.com) (or whatever) and load up some databases!
- Prefer [phpMyAdmin](http://www.phpmyadmin.net)? We won't hold it against you. Download it and unzip it to `util/phpMyAdmin` and copy [`util/config.inc.php`](util/config.inc.php) -> `/util/phpMyAdmin/`. Once you're done, pop open [precip.vm/phpMyAdmin](http://precip.vm/phpMyAdmin) and you're done.
- Or, even better: install [drush_sql_sync_pipe](https://www.drupal.org/project/drush_sql_sync_pipe), and import them straight from your remote environment of choice:
  - `$ drush sql-sync-pipe @remotesite.dev @vm.localsite --progress`

## Customize to your liking
If one isn't there already, the Puppet process will automatically create a settings.php for you. If you want to override settings, make a local-settings.inc right next to your settings.php and do whatever you want there. This is helpful to let you locally override Drupal Variables that may not be relevant for local development.

## Work Like Normal
With all that set you should be able to access whatever vhosts you set up in `config.rb`. Everything should _Just Work_. Use Git from the Host OS however you want. Same with Drush. Same with your IDE. Same with basically everything. And if you ever get things into an inconsistent state, you just have to nuke and rebuild Vagrant from scratch. It takes about 7 minutes.

# Other Cool Stuff

## The "util" vhost
There's a simple little "util" vhost set up at [precip.vm](http://precip.vm). It doesn't have a whole lot there right now, but it does have two things of note: [`index.php`](http://precip.vm/index.php) (phpinfo) and [`opcache.php`](http://precip.vm/opcache.php), which is an OpCache dashboard similar to the old `apc.php`.

This is also a helpful location for if you just need to test some stuff in a docroot without setting up a whole host directory or git clone, just toss the files in util and don't commit them.

## Logs
Each VirtualHost you define in `config.rb` automatically logs Apache errors to the `/log` directory which is conveniently outside the VM. You can use something like MacOS' "console" app to track them, or view them in a browser with [PimpMyLog](http://pimpmylog.com/), which has been installed and auto-configured for you at [precip.vm/pml](http://precip.vm/pml).

## Debugging Integration
[Xdebug](http://xdebug.org/) is built in and preconfigured. Use something like [Xdebug Helper](https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc?hl=en) to trigger a session, and your IDE should automagically pick it up.

## MailHog
[MailHog](https://github.com/mailhog/MailHog) is an alternative mailhandler written in Go. Similar to MailCatcher it collects mail sent by PHP (or, anything actually) and puts it in a friendly local web UI. Said web UI lives on port 8025: [precip.vm:8025](http://precip.vm:8025). The major benefit MailHog has over MailCatcher is that it's written in Go and is distributed as a statically-compiled binary, so we don't have a mile-long list of Ruby dependencies to reconcile before installing.

PHP is already set up to use it, but if for some reason you're making something that needs to directly talk to it, tell it there is *totally* an SMTP server at `smtp://localhost:1025`, and MailHog should take it from there.

## Adding additional repos - quick reference
- Clone your repo to a new directory under `/sites`
- Add a new entry to `/config.rb`
- Run `$ vagrant reload --provision` (full reload is needed for hostnames)
- Import SQL dump
- Add files directory (optional)
- Customize local-settings.inc (optional)

# Known Issues
- [x] ~~During Provisioning, Puppet complains about "Warning: Setting templatedir is deprecated." [It's a Vagrant Bug](https://github.com/mitchellh/vagrant/issues/3740).~~
- [ ] In migrating between VirtualBox 5.1.x and 5.2.x you may get a big angry red "Vagrant was unable to mount VirtualBox shared folders." fatal error on boot. Dumb Workaround: `vagrant reload --provision`.

# @TODO
- [x] ~~Puppet Library Caching~~
- [x] ~~Have Puppet compile Drush Aliases automagically~~
- [x] ~~Figure out Drupal 6 Support~~
- [x] ~~Build Drush into the box. Also Composer, Compass, etc.~~
- [x] ~~Rebrand with a catchy name~~
- [x] ~~Super Secret Automagical repo detection and cloning from config.rb~~
- [x] ~~phpMyAdmin support~~
- [x] ~~Actual Testing on Windows~~
- [x] ~~Figure out NFS support on Windows~~ (gave up)
- [x] ~~[Pimp My Log](http://pimpmylog.com) support~~
- [X] ~~Some sort of generalized environment pulldown script~~ (belongs elsewhere)
- [ ] A reasonable memcached dashboard
- [ ] Reduce repetition in `php.pp`
- [ ] Implement some sort of reasonable way to skip installation of some stuff (like, if you _really_ only need _one_ version of PHP)
- [ ] Other Cool Stuff?????

# Legal
**Precip** is in no way associated with Acquia, Inc. or Drupal. Drupal is a registered trademark of Dries Buytaert. **Precip** is available under the MIT License. Want to hack on it? Send a Pull Request. Find a bug? File an issue. (or a Pull Request) (preferably a Pull Request)
