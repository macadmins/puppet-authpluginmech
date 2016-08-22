Puppet::Type.newtype(:authpluginmech) do
    @doc = %q{Creates an entry in
    system.login.console

    Example:

        authpluginmech {'mymech':
          ensure       => present,
          entry        => 'Crypt:Check,privileged',
          insert_after => 'CryptoTokenKit:login'
        }
    }
    ensurable

      newparam(:entry, :namevar => true) do
        desc "The mechanism you want to apply."
      end

      newproperty(:insert_after) do
        desc "The entry we want to insert our entry after. Entry will be first if undefined."
        defaultto :none
      end
end
