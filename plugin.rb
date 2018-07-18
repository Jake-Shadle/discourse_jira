# name: discourse_jira
# about: Gives OneBox preview for 1 or more Jira hosts
# version: 1.0.0
# authors: Jake Shadle, Heather Boyer

Onebox = Onebox

# stylesheet
register_asset "stylesheets/jira.css"
register_asset "stylesheets/jira_mobile.scss", :mobile

module Onebox
  module Engine
    class JiraOnebox
      include Engine

      # See https://confluence.atlassian.com/display/JIRA/Changing+the+Project+Key+Format for a description of the Issue Id format
      # Support links in the format of https://hostname.org/browse/ISSUE-ID or https://hostname.org/projects/PROJECT/issues/ISSUE-ID 
      # Also supports grabbing a link that may have query string parameters.
      REGEX = /^(https?:\/\/[^\/]+)(?:.+)?\/(?:issues|browse)\/([A-Z][A-Z_]+-\d+)/
      matches_regexp(/^http.+\/(?:issues|browse)\/([A-Z][A-Z_]+-\d+).+$/)

      def id
        @url.match(REGEX)[2]
      end

      def domain
        @url.match(REGEX)[1]
      end

      def to_html

        url = domain + "/rest/api/latest/issue/" + id + '?fields=status,summary,reporter,issuetype,priority'
        response = Onebox::Helpers.fetch_response(url) rescue "{}"
        data = ::MultiJson.load(response)
        

        if not data or not data.key?('fields')
          "<span class='jira-issue'><a href='#{@url}'>#{id}</a><span>"
        else

          html = []

          cleanurl = @url
          if @url.include? "?"
            cleanurl = @url.split("?")[0]
          end

          closed = false
          if data['fields'].key?('status') && data['fields']['status']['name'] == 'Closed'
              closed = true
          end

          html.push("<aside class='onebox jira-issue#{(closed ? ' resolved' : ' open')}'>")

          # HEADER
          html.push("<header class='source'>")
          html.push("<a href='#{@url}' target='_blank'>#{cleanurl}</a>")
          html.push("</header>")

          # BEGIN BODY
          html.push("<article class='onebox-body'>")
  
          # USER AVATAR
          if data['fields'].key?('reporter')
            avatarUrl = data['fields']['reporter']['avatarUrls']['48x48']
            displayName = data['fields']['reporter']['displayName']

            html.push("<img src='#{avatarUrl}' class='thumbnail onebox-avatar' alt='#{displayName}'>")
          end

          # TITLE
          html.push("<h4><a href='#{@url}' target='_blank' class='jira-issue-key'>#{id}</a>")
          if data['fields'].key?('summary')
            summary = data['fields']['summary']

            html.push(" <span class='summary'>#{summary}</span>")
          end
          html.push("</h4>")

          # DETAILS
          html.push("<div class='date' style='margin-top:10px;'>")
            # ISSUE TYPE
            html.push("<div class='detail' style='margin-top:10px;'>")
            html.push("<strong class='name'>Type: </strong>") 
              if data['fields'].key?('issuetype')
                issueIconUrl = data['fields']['issuetype']['iconUrl']
                issueName = data['fields']['issuetype']['name']

                html.push("<img class='icon' src='#{issueIconUrl}' width='16' height='16'>")
                html.push(" #{issueName}")
              end
            html.push("</div>")

            # PRIORITY TYPE
            html.push("<div class='detail' style='margin-top:10px;'>")
            html.push("<strong class='name'>Priority: </strong>")
            if data['fields'].key?('priority')
              priorityIconUrl = data['fields']['priority']['iconUrl']
              priorityName = data['fields']['priority']['name']

              html.push("<img class='icon' src='#{priorityIconUrl}' width='16' height='16'>")
              html.push(" #{priorityName}")
            end
            html.push("</div>")
          html.push("</div>")

          # END BODY
          html.push("</article>")
  
          html.push("<div style='clear: both'></div>")
          html.push("</aside>")
          
          html.join('')
        end   
      end
    end
  end 
end


