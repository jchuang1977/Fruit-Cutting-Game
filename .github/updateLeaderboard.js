const fs = require('fs');

module.exports = async ({ github, context }) => {
    const query = `query($owner:String!, $name:String!, $issue_number:Int!) {
      repository(owner:$owner, name:$name){
        issue(number:$issue_number) {
          title
          bodyText
          author {
            avatarUrl(size: 24)
            login
            url
          }
          updatedAt
        }
      }
    }`;

    const variables = {
      owner: context.repo.owner,
      name: context.repo.repo,
      issue_number: context.issue.number,
    };

    const result = await github.graphql(query, variables);
    console.log(JSON.stringify(result, null, 2));

    const issue = result.repository.issue;

    const nameMatch = /👤 Name:\s*(.*)/.exec(issue.bodyText);
    const githubLinkMatch = /🔗 GitHub Profile Link:\s*(.*)/.exec(issue.bodyText);
    const messageMatch = /💬 Message:\s*(.*)/.exec(issue.bodyText);
    const scoreMatch = /Score:\s*(\d+)/.exec(issue.title);
    const dateMatch = /Game Result Submission:\s*(.*?) - Score:/.exec(issue.title);

    const name = nameMatch ? nameMatch[1].trim() : 'Unknown';
    const githubLink = githubLinkMatch ? githubLinkMatch[1].trim() : 'N/A';
    const message = messageMatch ? messageMatch[1].trim() : 'N/A';
    const score = scoreMatch ? parseInt(scoreMatch[1].trim()) : 'N/A';
    const date = dateMatch ? dateMatch[1].trim() : 'N/A';

    const newEntry = `| ${score} | [<img src="${issue.author.avatarUrl}" alt="${issue.author.login}" width="24" /> ${name}](${githubLink}) | ${message} | ${date} |\n`;

    const readmePath = 'README.md';
    let readme = fs.readFileSync(readmePath, 'utf8');

    // Update Recent Plays
    const recentPlaysSection = /<!-- Recent Plays -->[\s\S]*?<!-- \/Recent Plays -->/.exec(readme);
    if (recentPlaysSection) {
        let recentPlaysContent = recentPlaysSection[0];
        recentPlaysContent = recentPlaysContent.replace(/<!-- \/Recent Plays -->/, `${newEntry}<!-- \/Recent Plays -->`);

        const recentPlaysRows = recentPlaysContent.split('\n').filter(row => row.startsWith('|') && !row.includes('Score | Player | Message | Date'));

        if (recentPlaysRows.length > 20) recentPlaysRows.pop();

        const updatedRecentPlays = `<!-- Recent Plays -->\n| Score | Player | Message | Date |\n|-------|--------|---------|------|\n${recentPlaysRows.join('\n')}\n<!-- /Recent Plays -->`;
        readme = readme.replace(recentPlaysSection[0], updatedRecentPlays);
    }

    // Update Leaderboard
    const leaderboardSection = /<!-- Leaderboard -->[\s\S]*?<!-- \/Leaderboard -->/.exec(readme);
    if (leaderboardSection) {
        let leaderboardContent = leaderboardSection[0];
        leaderboardContent = leaderboardContent.replace(/<!-- \/Leaderboard -->/, `${newEntry}<!-- \/Leaderboard -->`);

        const leaderboardRows = leaderboardContent.split('\n').filter(row => row.startsWith('|') && !row.includes('Score | Player | Message | Date'));

        leaderboardRows.sort((a, b) => parseInt(b.match(/^\| (\d+) \|/)[1]) - parseInt(a.match(/^\| (\d+) \|/)[1]));

        if (leaderboardRows.length > 20) leaderboardRows.pop();

        const updatedLeaderboard = `<!-- Leaderboard -->\n| Score | Player | Message | Date |\n|-------|--------|---------|------|\n${leaderboardRows.join('\n')}\n<!-- /Leaderboard -->`;
        readme = readme.replace(leaderboardSection[0], updatedLeaderboard);
    }

    fs.writeFileSync(readmePath, readme, 'utf8');
    console.log('README.md updated successfully.');
};
