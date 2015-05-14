# name: discourse_jira
# about: Gives OneBox preview for 1 or more Jira hosts
# version: 1.0.0
# authors: Jake Shadle

# stylesheet
register_asset "stylesheets/jira.css"
register_asset "stylesheets/jira_mobile.scss", :mobile

class Onebox::Engine::JiraOnebox
  include Onebox::Engine

  # See https://confluence.atlassian.com/display/JIRA/Changing+the+Project+Key+Format for a description of the Issue Id format
  matches_regexp /^http.+\/browse\/([A-Z][A-Z_]+-\d+)$/

  def id
    @url.match(@@matcher)[1]
  end

  def to_html
    matches = @url.match(/(https?:\/\/[^\/]+)\/browse\/([A-Z][A-Z_]+-\d+)/)

    puts "JIRA TO_HTML ENCOUNTERED"

    puts matches[1]
    puts matches[2]

    data = ::MultiJson.load(Onebox::Helpers.fetch_response(matches[1] + "/rest/api/latest/issue/" + matches[2] + '?fields=status,summary,issuetype').body)
    
    puts "Response " + data.to_s

    if not data or not data.key?('fields')
      return <<HTML
<span class="jira-issue">
  <a href="#{url}">#{id}</a>
<span>
HTML
    end
    
    html = []

    puts "CHECKING STATUS"
    status = nil
    if data['fields'].key?('status')
      status = data['fields']['status']
    end

    closed = status.nil? && status['name'] == 'Closed'

    puts "IS CLOSED: " + closed.to_s
    html.push('<span class="jira-issue' + (closed ? ' resolved' : '') + '">')

    html.push('<a href="' + @url + '" class="jira-issue-key">')
    
    if data['fields'].key?('issuetype')
      html.push('<img class="icon" src="' + data['fields']['issuetype']['iconUrl'] + '">')
    end

    html.push(matches[2])

    html.push('</a>')
    html.push(' - ')

    if data['fields'].key?('summary')
      html.push('<span class="summary">')

      # Does this need sanitization?
      html.push(data['fields']['summary'])
      html.push('</span>')
    end

    # if status
    #   html.push('"("')
    #   html.push('<span class="jira-status">')
    #   html.push('<img class="icon" src="' + data.fields.status.iconUrl + '">')
    #   html.push('" ' + data.fields.status.name + '"')
    #   html.push('</span>')
    #   html.push('")"')
    # end

    html.push('</span>')

    return html.join('')
  end
end