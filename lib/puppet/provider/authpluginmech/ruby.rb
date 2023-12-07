require 'puppet/util/package'
require 'puppet/util/execution'
require 'tempfile'
Puppet::Type.type(:authpluginmech).provide(:ruby) do

    commands :security => '/usr/bin/security'

    def get_auth_plist
        begin
            output = security(['-q', 'authorizationdb', 'read', 'system.login.console'])
        rescue Puppet::ExecutionFailure => e
            Puppet.debug "#get_auth_plist had an error -> #{e.inspect}"
            return {}
        end
        return Puppet::Util::Plist.parse_plist(output)
    end

    def write_db(plist)
        input_plist = Puppet::Util::Plist.dump_plist(plist, :xml)
        file = Tempfile.new('input_plist')
        file.write(input_plist)
        file.close
        Puppet::Util::Execution.execute(['/usr/bin/security', 'authorizationdb', 'write', 'system.login.console'], :stdinfile => file.path)
        file.unlink
    end

    def in_plist(plist)
        if plist['mechanisms'].nil?
            Puppet.debug "#in_plist mechanisms is nil"
            return false
        end
        
        if plist['mechanisms'].include? resource[:entry]
            Puppet.debug "#in_plist returning true"
            return true
        else
            Puppet.debug "#in_plist returning true"
            return false
        end
    end

    def remove_mech
        plist = get_auth_plist()
        plist['mechanisms'].each {|mech|
            if mech == resource[:entry]
                Puppet.debug "#remove_mech removing #{mech}"
                plist['mechanisms'].delete(resource[:entry])
                break
            end
        }
        write_db(plist)
    end

    def add_mech
        plist = get_auth_plist()
        if resource[:insert_after] == :none
            plist['mechanisms'] = [resource[:entry]] + plist['mechanisms']
        else
            plist['mechanisms'].each_with_index {|mech, index|
                if mech == resource[:insert_after]
                    plist['mechanisms'].insert(index+1, resource[:entry])
                    break
                end
            }
        end
        write_db(plist)
    end

    def set_value(value=nil)
        # first make sure it's not in the list if it is already
        plist = get_auth_plist()
        if in_plist(plist)
            remove_mech()
        end

        add_mech()
    end

    def exists?
        plist = get_auth_plist()
        return in_plist(plist)
    end

    def create
        set_value()
    end

    def destroy
        remove_mech()
    end

    def insert_after
        plist = get_auth_plist()
        if resource[:insert_after] == :none
            if plist['mechanisms'][0] == resource[:entry]
                return :none
            else
                return plist['mechanisms'][0]
            end
        else
            plist['mechanisms'].each_with_index { |mech, index|
                if mech == resource[:entry]
                    return plist['mechanisms'][index-1]
                end
            }
        end
    end

    def insert_after=(value)
        set_value(value)
    end
end
