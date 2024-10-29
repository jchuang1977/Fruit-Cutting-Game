module.exports = async ({ github, context }) => {
    const query = `query($owner:String!, $name:String!, $issue_number:Int!) {
      repository(owner:$owner, name:$name){
        issue(number:$issue_number) {
          comments(first: 50, orderBy: {direction: DESC, field: UPDATED_AT}) {
            nodes {
              author {
                avatarUrl(size: 24)
                login
                url
              }
              url
              bodyText
              updatedAt
            }
          }
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

    const renderComments = (comments) => {
        return comments.reduce((prev, curr) => {
            let sanitizedText = curr.bodyText
                .replace('<', '&lt;')
                .replace('>', '&gt;')
                .replace(/(\r\n|\r|\n)/g, "<br />")
                .replace('|', '&#124;')
                .replace('[', '&#91;');

            // Convert updatedAt to a date with UTC+7 timezone
            let date = new Date(curr.updatedAt);
            let formattedDate = date.toLocaleString('en-US', { timeZone: 'Asia/Ho_Chi_Minh' });

            // Extracting details from the comment body
            const nameMatch = /#### 👤 \*\*Name\*\*:\s*(.*)/.exec(curr.bodyText);
            const githubLinkMatch = /#### 🔗 \*\*GitHub Profile Link\*\*:\s*(.*)/.exec(curr.bodyText);
            const messageMatch = /#### 💬 \*\*Message\*\*:\s*(.*)/.exec(curr.bodyText);
            const screenshotMatch = /#### 🖼️ \*\*Screenshot\*\*[\s\S]*?\((.*?)\)/.exec(curr.bodyText);

            const name = nameMatch ? nameMatch[1].trim() : 'Unknown';
            const githubLink = githubLinkMatch ? githubLinkMatch[1].trim() : 'N/A';
            const message = messageMatch ? messageMatch[1].trim() : 'N/A';
            const screenshot = screenshotMatch ? screenshotMatch[1].trim() : 'N/A';

            return `${prev}| [<img src="${curr.author.avatarUrl}" alt="${curr.author.login}" width="24" />  ${name}](${githubLink}) | ${message} | ![Screenshot](${screenshot}) | ${formattedDate} |\n`;
        }, "| Player | Message | Screenshot | Date |\n|---|---|---|---|\n");
    };

    const fileSystem = require('fs');
    const readmePath = 'README.md';
    let readme = fileSystem.readFileSync(readmePath, 'utf8');

    // Update leaderboard section
    const updatedContent = readme.replace(/(?<=<!-- Leaderboard -->.*\n)[\S\s]*?(?=<!-- \/Leaderboard -->|$(?![\n]))/gm, renderComments(result.repository.issue.comments.nodes));
    fileSystem.writeFileSync(readmePath, updatedContent, 'utf8');
    console.log('README.md updated successfully.');
};
