#!/usr/bin/ruby
require 'json'
require 'curb'
require 'yaml'

class Jira
  def initialize
    #TODO set baseurl when first time install
    @base_url = "http://jira.yourcompany.com/rest/api/2/"
    current_path = File.expand_path("../", __FILE__)
    @username = YAML.load_file("#{current_path}/config.yml")['username']
    @password = YAML.load_file("#{current_path}/config.yml")['password']
  end

  def filter(query)
    sq = {}
    sq['jql'] = case query
                  when 'all'
                    '(assignee = CurrentUser() OR "QA Assignee" = CurrentUser() OR "Dev Assignee" = CurrentUser() or reporter=CurrentUser()) ORDER BY updatedDate DESC'
                  when 'dev'
                    'project = INK and "Dev Assignee"=CurrentUser() and "Submitted Due" <= endOfWeek() and status in (OPEN, DEVELOPING, "All Codes Submitted", REVIEWING)'
                  when 'qa'
                    'project = INK and "QA Assignee"=CurrentUser() and "Tested Due" <= endOfWeek() and status in (OPEN, DEVELOPING, "All Codes Submitted", REVIEWING, REVIEWED, TESTING)'
                  else
                    query
                end
    sq['maxResults'] = "100"
    sq['fields'] = ['key', 'summary']
    result = post("search", sq)
    result['issues'].each { |issue| puts '*'+issue['key']+' '+issue['fields']['summary'] } rescue puts "Invalid query or Filter result is empty"
  end

  def process_ticket(ticket, event, comment = nil)
    @ticket = ticket.upcase.gsub('_', '-')
    case event
      when 'comment'
        comment_ticket comment
      when 'show'
        show_ticket
      when 'logwork'
        logwork comment
      when 'branch'
        checkout_new_branch
      when 'delete'
        delete_branch
      when 'available'
        show_ticket_transition
      when 'transition'
        change_status_to comment
    end
  end

  protected

  def comment_ticket(comment)
    post("issue/#{@ticket}/comment", {:body => comment})
    puts "comment on #{@ticket} #{comment}"
  end

  def show_ticket
    get_ticket_info
    puts "="*70 + "\n #{@ticket_title} \n Priority is #{@ticket_priority} \n Version  is #{@ticket_version} \n Status   is #{@ticket_status} \n Reporter is #{@ticket_reporter} \n Assignee is #{@ticket_assignee} \n Dev      is #{@ticket_dev_assignee} \n QA       is #{@ticket_qa_assignee} \n"
    puts "="*25 + " Ticket description:" + "="*25 + " \n #{@ticket_description} \n" + "="*70
  end

  def logwork(comment)
    time = comment.match(/^(\d|\.)+(m|d|h)/)[0]
    post("issue/#{@ticket}/worklog", {:timeSpent => time, :comment => comment})
  end

  def change_status_to(status)
    trans = get_ticket_transition
    status_id = trans[status.downcase]
    return puts "#{@ticket} available transitions are #{trans.keys.to_s.downcase}." if status_id.nil?
    params = {:transition => {:id => status_id}}
    post("issue/#{@ticket}/transitions", params)
    get_ticket_info
    puts "#{@ticket} status is #{@ticket_status}"
  end

  def show_ticket_transition
    trans = get_ticket_transition
    puts "#{@ticket} available transitions are #{trans.keys.to_s.downcase}."
  end

  def checkout_new_branch
    puts `git rev-parse --abbrev-ref HEAD | xargs echo "You are on branch$5"`
    `git checkout -b #{get_branch_name}`
  end

  def delete_branch
    `git branch -D #{get_branch_name}`
    puts `git rev-parse --abbrev-ref HEAD | xargs echo "You are on branch$5"`
  end

  private
  def get(relative_url)
    response = Curl.get(@base_url + relative_url) do |request|
      request.username = @username
      request.password = @password
      request.http_auth_types = :basic
      request.on_missing { |req| puts "Can't find the ticket #{@ticket}" }
    end
    parse_api_response(response)
  end

  def post(relative_url, params)
    response = Curl.post(@base_url+relative_url, params.to_json) do |request|
      request.username = @username
      request.password = @password
      request.http_auth_types = :basic
      request.headers['Content-Type'] = 'application/json'
      request.on_success { |req| puts "Success" }
      request.on_failure { |req| puts "Failed" }
      request.on_missing { |req| puts "Can't find the ticket #{@ticket}" }
    end
    parse_api_response(response)
  end

  def get_ticket_info
    ticket_info = get("issue/#{@ticket}")
    @ticket_title = ticket_info['key']+" "+ticket_info['fields']['summary']
    @ticket_reporter = ticket_info['fields']['reporter']['displayName'] rescue "Nobody"
    @ticket_assignee = ticket_info['fields']['assignee']['displayName'] rescue "Nobody"
    @ticket_qa_assignee = ticket_info['fields']['customfield_10035']['displayName'] rescue "Nobody"
    @ticket_dev_assignee = ticket_info['fields']['customfield_10034']['displayName'] rescue "Nobody"
    @ticket_description = ticket_info['fields']['description'] rescue "Empty"
    @ticket_status = ticket_info['fields']['status']['name'] rescue "Empty"
    @ticket_priority = ticket_info['fields']['priority']['name'] rescue "Empty"
    @ticket_version = ticket_info['fields']['fixVersions'].first['name'] rescue "Can't get"
  end

  def get_ticket_transition
    ticket_transition = get("issue/#{@ticket}/transitions")
    available_transitions = {}
    ticket_transition['transitions'].each { |tran| available_transitions[tran['name'].downcase]=tran['id'] unless available_transitions.has_key?(tran['name'].downcase) }
    available_transitions
  end

  def get_branch_name
    get_ticket_info
    'd_'+@ticket_title.downcase.split(/\W+/).join("_").gsub(/_+/, "_")
  end

  def parse_api_response(response)
    JSON.parse(response.body_str) unless response.body_str.empty?
  rescue JSON::ParserError => parse_error
    puts "Failed due to json parse error \n #{parse_error}"
  end
end
