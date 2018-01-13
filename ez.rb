require 'getoptlong'
require_relative 'jira.rb'

no_arg_options = %w(-f --filter -h --help)

if no_arg_options.include?(ARGV[0])
  #do nothing
elsif ARGV[0] == 'help'
  ARGV[0] = '-h'
elsif ARGV[0].nil?
  puts "Your command line is invalid, please try ez help"
else
  ticket = ARGV[0]
  ARGV.shift
  puts "Jira ticket key is missing. Valid command line is ez INK-xxx [OPTION]" if ARGV[0].nil?
end

opts = GetoptLong.new(
    ['--help', '-h', GetoptLong::NO_ARGUMENT],
    ['--branch', '-b', GetoptLong::NO_ARGUMENT],
    ['--delete', '-d', GetoptLong::NO_ARGUMENT],
    ['--show', '-s', GetoptLong::NO_ARGUMENT],
    ['--available', '-a', GetoptLong::NO_ARGUMENT],
    ['--comment', '-c', GetoptLong::REQUIRED_ARGUMENT],
    ['--logwork', '-l', GetoptLong::REQUIRED_ARGUMENT],
    ['--transition', '-t', GetoptLong::REQUIRED_ARGUMENT],
    ['--filter', '-f', GetoptLong::REQUIRED_ARGUMENT]
)

begin
  opts.each do |opt, arg|
    case opt
      when '--help'
        puts <<-EOF
  Usage:
    ez INK-xxx [OPTION] ...

    No Argument Options:
      -b, --branch                    #Will checkout a new branch based on your current DIR named d_ink_xxx_the_title_of_ticket
      -d, --delete                    #Will delete the branch d_ink_xxx_the_title_of_ticket based on your current DIR
      -s, --show                      #Will show INK-xxx detail info
      -a, --available                 #Will show INK-xxx's available status transition

    Require Argument Options
      -c, --comment "string"          #Will add the comment "string" to INK-xxx
      -l, --logwork "2.5h string"     #Will log 2.5h to INK-xxx with the description "string", 2.5h must be the first word.
      -t, --transition "tested"       #Will change INK-xxx's status to TESTED. You could get ticket's available transitions by using ez INK-xxx -a
                                      #If the argument is not a valid transition. Will return

  Advanced Usage
    ez -h, --help, help               #Will show help
    ez -f, --filter "query"

      Examples:
        ez -f all                     #Will return all JIRA tickets related to you, the max ticket num is 100
        ez -f dev                     #Will return the INK tickets you need to deal with in this week as the Dev Assignee
        ez -f qa                      #Will return the INK tickets you need to deal with in this week as the QA Assignee
        ez -f "Project = OPP and 'Dev Assignee' = CurrentUser()"
                                      #Will return the result of your customized Jira filter.
  Tips:
    * INK-123, ink-123, opp_345 , Et-456 are all valid
    * You could use ez combined with shell command, like "ez -f all |grep INK |grep Upfront"
    * You could also customized some alias in your bash/zsh profile

        EOF
      when '--branch'
        Jira.new.process_ticket(ticket, 'branch')
      when '--delete'
        Jira.new.process_ticket(ticket, 'delete')
      when '--show'
        Jira.new.process_ticket(ticket, 'show')
      when '--available'
        Jira.new.process_ticket(ticket, 'available')
      when '--comment'
        Jira.new.process_ticket(ticket, 'comment', arg)
      when '--logwork'
        Jira.new.process_ticket(ticket, 'logwork', arg)
      when '--transition'
        Jira.new.process_ticket(ticket, 'transition', arg)
      when '--filter'
        Jira.new.filter(arg) rescue "Invalid query"
    end
  end
rescue Exception => e
  puts "Your command line is invalid, please try ez help"
end

puts "Your command line seems incorrect, there are extra arguement #{ARGV}. Please try ez help." unless ARGV[0].nil?


