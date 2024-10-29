module.exports = async ({ github, context }) => {
    const query = `query($owner:String!, $name:String!, $issue_number:Int!) {
      repository(owner:$owner, name:$name){
        issue(number:$issue_number) {
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

    // Lấy thông tin từ body của issue
    const issue = result.repository.issue;

    // Chúng ta sẽ phân tích body của issue
    const sanitizedText = issue.bodyText
      .replace('<', '&lt;')
      .replace('>', '&gt;')
      .replace(/(\r\n|\r|\n)/g, "<br />")
      .replace('|', '&#124;')
      .replace('[', '&#91;');

    // Chuyển đổi updatedAt thành ngày với múi giờ UTC+7
    let date = new Date(issue.updatedAt);
    let formattedDate = date.toLocaleString('en-US', { timeZone: 'Asia/Ho_Chi_Minh' });

    const nameMatch = /#### 👤 \*\*Name\*\*:\s*<!--START_SECTION:Name-->(.*?)<!--END_SECTION:Name-->/s.exec(issue.bodyText);
    const githubLinkMatch = /#### 🔗 \*\*GitHub Profile Link\*\*:\s*<!--START_SECTION:GitHub-->(.*?)<!--END_SECTION:GitHub-->/s.exec(issue.bodyText);
    const messageMatch = /#### 💬 \*\*Message\*\*:\s*<!--START_SECTION:Message-->(.*?)<!--END_SECTION:Message-->/s.exec(issue.bodyText);
    const screenshotMatch = /#### 🖼️ \*\*Screenshot\*\*\s*<!--START_SECTION:Screenshot-->(.*?)<!--END_SECTION:Screenshot-->/s.exec(issue.bodyText);

    const name = nameMatch ? nameMatch[1].trim() : 'Unknown';
    const githubLink = githubLinkMatch ? githubLinkMatch[1].trim() : 'N/A';
    const message = messageMatch ? messageMatch[1].trim() : 'N/A';
    const screenshot = screenshotMatch ? screenshotMatch[1].trim() : 'N/A';

    const newEntry = `| [<img src="${issue.author.avatarUrl}" alt="${issue.author.login}" width="24" />  ${name}](${githubLink}) | ${message} | ![Screenshot](${screenshot}) | ${formattedDate} |\n`;

    const fileSystem = require('fs');
    const readmePath = 'README.md';
    let readme = fileSystem.readFileSync(readmePath, 'utf8');

    // Cập nhật phần leaderboard
    const updatedContent = readme.replace(/(?<=<!-- Leaderboard -->.*\n)[\S\s]*?(?=<!-- \/Leaderboard -->|$(?![\n]))/gm, newEntry);
    
    fileSystem.writeFileSync(readmePath, updatedContent, 'utf8');
    console.log('README.md updated successfully.');
};
