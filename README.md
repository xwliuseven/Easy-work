# Easy Work

Customize some command lines to make our work quicker and easier.

## Install && update 
Execute command line below in your terminal

For Bash User
```
sh -c "`curl -fsSL https://github.com/xwliuseven/Easy-work/raw/master/install.sh`" && source ~/.bash_profile
```
For Zsh User
```
export PROFILE=~/.zshrc && sh -c "`curl -fsSL https://github.com/xwliuseven/Easy-work/raw/master/install.sh`" && source $PROFILE
```

## Supported functionalities
You can use these command lines to show/modify all kinds of Jira tickets.

### Show ticket info
```
ez OPP-123 -s
ez OPP-123 --show
```
Will show OPP-123's title, fixversion, status, assignees and description

### Comment on jira ticket
```
ez INK-123 -c "the comment you want to add to INK-123"
ez INK-123 --comment "the comment you want to add to INK-123"
```
Will add the comment you write to ET-123, the comment content is required.

### Logwork on jira ticket
```
ez INK-123 --logwork "2h the work description"
ez INK-123 -l "2h the work description"
```
Will log work 2h to INK-123, support (2h|30m|1d). The comment should start with the time you want to log.

### Change ticket status
```
ez INK-123 -a
ez INK-123 --avaiable
```
Will return the ticket's avaiable status transitions
```
ez INK-123 -t (open|'start review'|finished)
ez INK-123 --transition (open|'start review'|finished)
```
Will change INK-123 status to (open|reviewing|finished). (May fail when finish an INK due to is_regression not checked)

```
ez INK-123 -t "invalid transition"
```
If you give a wrong transition argument, ez will return the ticket's available transition event. Like: 'INK-123 available transitions are ["open", "start dev"].'

### Checkout a new git branch or delete a branch
```
ez INK-123 -b
ez INK-123 --branch
```
Will checkout a new branch named d_ink_123_title_of_this_jira_ticket

```
ez INK-123 -d
ez INK-123 --delete
```
Will delete the branch named d_ink_123_title_of_this_jira_ticket

### Jira filter
```
ez -f all                     #Will return all JIRA tickets related to you, the max ticket num is 100
ez -f dev                     #Will return the INK tickets you need to deal with in this week as the Dev Assignee
ez -f qa                      #Will return the INK tickets you need to deal with in this week as the QA Assignee
ez -f "Project = OPP and 'Dev Assignee' = CurrentUser()"
                              #Will return the result of your customized Jira filter.
```
or
```
ez --filter all               #Will return all JIRA tickets related to you, the max ticket num is 100
ez --filter dev               #Will return the INK tickets you need to deal with in this week as the Dev Assignee
ez --filter qa                #Will return the INK tickets you need to deal with in this week as the QA Assignee
ez --filter "Project = OPP and 'Dev Assignee' = CurrentUser()"
                              #Will return the result of your customized Jira filter.
```
Jira filter
- all => '(assignee = CurrentUser() OR "QA Assignee" = CurrentUser() OR "Dev Assignee" = currentUser() or reporter=CurrentUser()) ORDER BY updatedDate DESC'. The maxnum of result is 100.
- dev => 'project = INK and "Dev Assignee"=CurrentUser() and "Submitted Due" <= endOfWeek() and status in (OPEN, DEVELOPING, "All Codes Submitted", REVIEWING)'
- qa  => 'project = INK and "QA Assignee"=CurrentUser() and "Tested Due" <= endOfWeek() and status in (OPEN, DEVELOPING, "All Codes Submitted", REVIEWING, REVIEWED, TESTING)'


You could use ez combined with shell command
```
ez -f "project = INK and assignee = CurrentUser() and fixversion=6.6" | grep Upfront
```

Also you can write alias for your frequent used filter in your bash_profile/zshrc like below
```
alias filter_viewed="ez --filter '\"QA Assignee\"= CurrentUser() and project = INK and status = REVIEWED'"
alias filter_open="ez --filter '\"Dev Assignee\"= CurrentUser() and project = INK and status = OPEN'"
alias filter_developing="ez --filter '\"Dev Assignee\"= CurrentUser() and project = INK and status = DEVELOPING'"
```
### Show Usage
```
ez -h, --help, help
```
Will show usage

## Tips
- `All kinds Jira tickets are supported. Include INK OPP ET.`
- `INK-123, ink-123 ,iNk_123 are all valid`
- If you meet an "unexpected token" error, maybe your username/password is incorrect. Please execute installation command line again and recorrect your username/password.

## Reference
- [Jira Rest API](https://docs.atlassian.com/jira/REST/latest/)
- [Curb](http://taf2.github.io/curb/)
- [Getoptlong](http://ruby-doc.org/stdlib-1.9.3/libdoc/getoptlong/rdoc/GetoptLong.html)

Any suggestion is welcome~ Please contact xwliuseven@gmail.com
