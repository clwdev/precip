vagrant-ac-drupal - A Cloud-oriented Drupal Vagrant Environment
===============================================================
[Vagrant](http://www.vagrantup.com) is the CLI frontend VirtualBox should have shipped with. It makes working with Virtual Machines not horrible, and when you combine it with a provisioning system like [Puppet](http://www.puppetlabs.com), you can take simple off-the-shelf VMs and automatically configure them to match effectively any server configuration you can imagine.

Vagrant gives you the best of both worlds for development: you can be sure your server matches production identically, there's never any mystery as to how your environment is being created, everything is completely reproducible, and you can still use your local IDEs and such however you want due to effortless directory sharing.

*This time* the box is geared towards Drupal, and specifically Drupal hosted in an environment like Acquia Cloud.

## Why not build your own box from scratch?
This repo offers a few key benefits over just rolling your own Vagrant setup that might not be immediately apparent when you start messing around with Vagrant.
- **One box for many sites** - It's common to see single-purpose Vagrant boxes. I think that's less than ideal, because who wants to allocate a bunch of dedicated resources for every box, or constantly juggle running VMs? Here you can have one box to host an arbitrary number of sites.
- **Simple Virtualhost Configuration** - [config.rb](config.rb-dist) lets you easily set up a bunch of Apache Virtualhosts without having to hack on the Vagrantfile, Puppet, or the live box itself. It also has friendly config options to tweak bits of your Drupal environment, like multi-site directories, domain aliases and so on.
- **All data lives outside of the box** - Your actual project repos, MySQL data directories and log files all live outside of the Vagrant box and will survive both the box being reprovisioned *and* completely being blown out and rebuilt from scratch. Getting this to work in a sane way required me to write a [Vagrant plugin](https://github.com/jeffgeorge/vagrant-useradd), so I doubt you'll find another Vagrant box that does this.
- **Easily Extensible** - Figuring out your base Puppet config to get a functional server can be daunting. Here it's mostly done. Want to add an extra PHP module or something? It's probably one line and easily testable, versus having to Puppet-ize your whole box config first.

Setting Up Your Clones
======================
This repo consists of *just* the Vagrant environment configuration, so before you start, you should have some Git Clones set up for the various sites you'll be working with. Drop those in `/drupal_sites`. (Note that they don't *have* to be Drupal, you can just as easily drop in arbitrary PHP sites that need a docroot built and a database provisioned.)

Once you've got all your clones ready, it's time to play with Vagrant.

Setting Up Vagrant
==================
## Get Virtualbox & Vagrant
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Vagrant](http://www.vagrantup.com/downloads.html)
- Install both
- You'll also need some Vagrant Plugins (if you forget, it'll install them for you)
  - `$ vagrant plugin install vagrant-vbguest`
  - `$ vagrant plugin install vagrant-hostsupdater`
  - `$ vagrant plugin install vagrant-useradd` _(I made this!)_
  - `$ vagrant plugin install vagrant-bindfs`

## Clone this repo
- Do it

## Set up your host and path information
- Edit `/config.rb-dist` and fill out in the blanks
  - I like using sitename.vm. It isn't a valid TLD and makes it clear that you're talking about a local VM.
- Save it as `/config.rb`

## Vagrant first-time setup
- In the git clone, fire up vagrant with
  - `$ vagrant up`
  - This will probably take a geologic age, as Vagrant first has to go get the base box
- Once it finishes downloading the base box it will hand off to Puppet for provisioning
- Once it finishes you'll have the VM up and running!

## Updating Vagrant
- If you do a `$ git pull` and see that the `Vagrantfile` has been updated, you may want to make sure things are up to date by running `$ vagrant reload --provision`.
- If things ever get weird for whatever reason, you can always completely nuke and rebuild the box with `$ vagrant destroy -f && vagrant up`.
- Don't be afraid of doing that. It's not destructive to your data, and only takes about 7 minutes.

Actually Using It
=================
So you've got your Clones and you've got Vagrant running. . . now what?

## Importing Databases
- You've got a database server at root:drupal@drupal.vm!
- Connect with SequelPro (or whatever) and load up some databases!

## Customize to your liking
If one isn't there already, the Puppet process will automatically create a settings.php for you. If you want to override settings, make a local-settings.inc right next to your settings.php and do whatever you want there.

## Work Like Normal
With that set, you should be able to access whatever vhosts you set up in `config.rb`. Unless you used .com domains, you'll likely need to access them with an explicit `http://` or Chrome will freak out. But apart from that, everything should Just Work. Use Git from the Host OS however you want. Same with Drush. Same with your IDE. Same with basically everything.

If you ever get things into an inconsistent state, nuke and rebuild Vagrant from scratch. It takes about 5 minutes. If you want to work on proposed changes to the VM stack (like, swapping MySQL to MariaDB, or upgrading to PHP 5.6 or _whatever_), feel free to test it and submit a pull request.

Other Cool Stuff
=================
## The "util" vhost
There's a simple little "util" vhost set up at [drupal.vm](http://drupal.vm). It doesn't have a whole lot set up right now, but it does have two things of note: `index.php` (phpinfo) and `opcache.php`, which is an OpCache dashboard similar to the old apc.php.

This is also a helpful location for if you just need to test some stuff in a docroot without setting up a whole host directory or git clone, just toss the files in util and don't commit them.

## Logs
Want Apache Logs? Don't want to SSH into the VM and sudo to root and other terrible things? Good! They're in the `/log` directory. Load them up however you want, for instance, with OSX's nice `Console` app.

## Debugging Integration
[Xdebug](http://xdebug.org/) is built in and preconfigured. Use something like [Xdebug Helper](https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc?hl=en) to trigger a session, and your IDE should automagically pick it up.

The [XHProf PHP Extension](http://php.net/manual/en/book.xhprof.php) is also built in. There's a [pretty nice Drupal Module](https://www.drupal.org/project/xhprof) that can hook into it.

## MailCatcher
[MailCatcher](http://mailcatcher.me) is a magic Ruby app that acts as a mailhandler. Instead of actually sending mail, it just collects it and makes it available to you in a nice local web UI. Said web UI lives on port 1080: [ac-drupal.vm:1080](http://ac-drupal.vm:1080).

PHP is already set up to use it, but if for some reason you're making something that needs to directly talk to it, tell it there is *totally* an SMTP server at `smtp://localhost:1025`, and MailCatcher should take it from there.

## Adding additional repos - quick reference
- Clone repo to the division directory (nae or nas)
- Add site entry to `config.rb`
- Run `vagrant reload --provision`
- Import SQL dump
- Add files directory (optional)
- Customize settings.php (optional)
- Add debug profile to IDE (optional)

Known Issues
============
- [ ] During Provisioning, Puppet complains about "Warning: Setting templatedir is deprecated." [It's a Vagrant Bug](https://github.com/mitchellh/vagrant/issues/3740).
- [ ] Files created by Puppet in a shared directory appear to be written with a 555 umask, making them un-deleteable from the host (without root)

@TODO
=====
- [ ] Puppet Library Caching (if you've got librarian-puppet locally installed)
- [ ] Have Puppet compile Drush Aliases automagically
- [ ] Figure out Drupal 6 Support
- [ ] Super Secret Automagical repo detection and cloning from config.rb
- [ ] Actual Testing on Windows
- [ ] Build Drush into the box. Also Composer, Compass, etc. (as an option, at least)
- [ ] Some sort of generalized environment pulldown script
- [ ] Other Cool Stuff

Legal
=====
vagrant-ac-drupal is in no way associated with Acquia Inc or Drupal. Drupal is a registered trademark of Dries Buytaert. vagrant-ac-drupal is available under the MIT License. Want to hack on it? Send a Pull Request. Find a bug? File an issue. (or a Pull Request) (preferably a Pull Request)