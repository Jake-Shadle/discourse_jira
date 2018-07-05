# name: discourse_jira
# about: Gives OneBox preview for 1 or more Jira hosts
# version: 2.0.0
# authors: Jake Shadle

Onebox = Onebox

# stylesheet
register_asset "stylesheets/jira.css"
register_asset "stylesheets/jira_mobile.scss", :mobile

module Onebox
  module Engine
    class JiraOnebox
      include Engine

      Onebox.options = {
        cache: Rails.cache
      }

      # See https://confluence.atlassian.com/display/JIRA/Changing+the+Project+Key+Format for a description of the Issue Id format
      REGEX = /^(https?:\/\/[^\/]+)(?:.+)?\/(?:issues|browse)\/([A-Z][A-Z_]+-\d+)/
      matches_regexp(/^http.+\/(?:issues|browse)\/([A-Z][A-Z_]+-\d+).+$/)

      def id
        @url.match(REGEX)[2]
      end

      def domain
        @url.match(REGEX)[1]
      end

      def to_html

        url = domain + "/rest/api/latest/issue/" + id + '?fields=status,summary,issuetype'
        response = Onebox::Helpers.fetch_response(url) rescue "{}"
        data = ::MultiJson.load(response)

        if not data or not data.key?('fields')
          "<span class='jira-issue'><a href='#{@url}'>#{id}</a><span>"
        else

          closed = false
          if data['fields'].key?('status')
            if data['fields']['status']['name'] == 'Closed'
              closed = true
            end
          end

          issueicon = ""
          if data['fields'].key?('issuetype')
            iconurl = data['fields']['issuetype']['iconUrl']
            issueicon = "<img class='icon' src='#{iconurl}'>"
          end

          issuesummary = ""
          if data['fields'].key?('summary')
            summary = data['fields']['summary']
            issuesummary = "<span class='summary'>#{summary}</span>"
          end
          
          "<span class='jira-issue#{(closed ? ' resolved' : ' open')}'><a href='#{@url}' class='jira-issue-key'>#{issueicon} #{id}</a> - #{issuesummary}"
        end   
      end
    end
  end 
end


