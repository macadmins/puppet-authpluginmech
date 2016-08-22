This is a type and provider to manage mechanisms in the `system.login.console` section of macOS' authorization database. Why might you want to use this? Let's say you're deploying an authorization plugin, such as [Crypt](https://github.com/grahamgilbert/crypt2) and you upgrade to an unreleased version of macOS. You may find that your `system.login.console` right has been reset to it's default state and your authorization plugins won't run. This clearly is a bad thing.

## Usage

``` puppet
authpluginmech { 'Crypt:Check,privileged':
    ensure       => 'present',
    insert_after => 'MCXMechanism:login'
}
```

In this example, the namevar is the mechanism you wish to add in. We have told it to insert it after `MCXMechanism:login` (as the mechanisms are called in order, so this matters). You can also explicitly set the mechanism.

``` puppet
authpluginmech { 'My Awesome mech:
    ensure       => 'present',
    entry        => 'Crypt:Check,privileged',
    insert_after => 'MCXMechanism:login'
}
```
