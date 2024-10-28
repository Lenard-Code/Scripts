<#
.SYNOPSIS
    Parses a JSON file containing MS Teams messages, contacts, and meetings to rebuild conversations and print details to the console. This directory is located %AppData%\AppData\Roaming\Microsoft\Teams\IndexedDB\https_teams.microsoft.com_0.indexeddb.leveldb

.DESCRIPTION
    The Rebuild-Conversations function reads and parses a JSON file, separates messages, contacts, files shared and meetings.
    It groups messages by 'conversationId', sorts them by 'createdTime', removes occurrences of 'Â' and newlines from message content, and prints the conversation details to the console.
    For conversations starting with '19:meeting', it extracts and displays meeting details including creator, event type, meeting type, subject, meeting duration, start time, end time, and the number of members.

.PARAMETER JsonFilePath
    The path to the JSON file to be parsed.

.EXAMPLE
    # Call the function to rebuild conversations
    Rebuild-TeamsConversations -JsonFilePath $jsonFilePath
#>

function Rebuild-TeamsConversations {
    param (
        [string]$JsonFilePath
    )

    # Read and parse JSON file
    $jsonData = Get-Content -Path $JsonFilePath | ConvertFrom-Json

    # Separate messages and contacts
    $messages = $jsonData | Where-Object { $_.record_type -eq "message" }
    $contacts = $jsonData | Where-Object { $_.record_type -eq "contact" }
    $meetings = $jsonData | Where-Object { $_.record_type -eq "meeting" }

    # Create a hashtable to map mri to displayName
    $mriToDisplayName = @{}
    foreach ($contact in $contacts) {
        $mriToDisplayName[$contact.mri] = $contact.displayName
    }

    # Group messages by conversationId and sort by createdTime
    $groupedConversations = $messages | Group-Object -Property conversationId

    foreach ($conversation in $groupedConversations) {
        Write-Host "############ Begin of Conversation #################" -ForegroundColor Green
        Write-Host "Conversation ID: $($conversation.Name)"

        $sortedMessages = $conversation.Group | Sort-Object -Property createdTime

        # Check if conversationId starts with '19:meeting'
        if ($conversation.Name -like "19:meeting*") {
            $meeting = $meetings | Where-Object { $_.id -eq $conversation.Name }
            if ($meeting) {
                $creator = $mriToDisplayName[$meeting.threadProperties.creator]
                $eventType = $meeting.threadProperties.meeting.eventType
                $meetingType = $meeting.threadProperties.meeting.meetingType
                $subject = $meeting.threadProperties.meeting.subject
                $membersCount = $meeting.members.Count
                $meetingDuration = $meeting.threadProperties.meetingContent.recording.latestRecording.duration
                $meetingStartTime = $meeting.threadProperties.meeting.startTime
                $meetingEndTime = $meeting.threadProperties.meeting.endTime

                Write-Host "Meeting Details:"
                Write-Host "Creator: $creator"
                Write-Host "Event Type: $eventType"
                Write-Host "Meeting Type: $meetingType"
                Write-Host "Subject: $subject"
                Write-host "Meeting Duration: $meetingDuration"
                Write-host "Meeting Start Time: $meetingStartTime"
                Write-host "Meeting End Time: $meetingEndTime"
                Write-Host "Number of Members: $membersCount"
                Write-Host "Chat log:"
            }
        }

        foreach ($message in $sortedMessages) {
            # Remove any occurrence of 'Â ' and newlines from message content
            $message.content = $message.content -replace 'Â', ''
            $message.content = $message.content -replace "`n", ''
            $message.content = $message.content -replace "`r", ''

            $creator = $mriToDisplayName[$message.creator]
            $content = $message.content
            $createdTime = $message.createdTime

            Write-Host "[$createdTime] ${creator}: ${content}"

            # List emotions used on the message
            if ($message.properties.emotions) {
                foreach ($emotion in $message.properties.emotions) {
                    $emotionType = $emotion.key
                    $users = $emotion.users | ForEach-Object { $mriToDisplayName[$_.mri] }

                    Write-Host "  Emotions - ${emotionType}: $($users -join ', ')"
                }
            }
        }
        
        Write-Host "############ End of Conversation ##################`n" -ForegroundColor Green
    }
}