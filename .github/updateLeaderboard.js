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

    // Lấy thông tin từ body và title của issue
    const issue = result.repository.issue;

    // Phân tích nội dung body của issue
    const nameMatch = /👤 Name:\s*(.*)/.exec(issue.bodyText);
    const githubLinkMatch = /🔗 GitHub Profile Link:\s*(.*)/.exec(issue.bodyText);
    const messageMatch = /💬 Message:\s*(.*)/.exec(issue.bodyText);
    const scoreMatch = /Score:\s*(\d+)/.exec(issue.title); // Lấy score từ tiêu đề

    const name = nameMatch ? nameMatch[1].trim() : 'Unknown';
    const githubLink = githubLinkMatch ? githubLinkMatch[1].trim() : 'N/A';
    const message = messageMatch ? messageMatch[1].trim() : 'N/A';
    const score = scoreMatch ? scoreMatch[1].trim() : 'N/A'; // Lấy giá trị score

    // Logging để kiểm tra
    console.log(`Title: ${issue.title}`);
    console.log(`Name: ${name}`);
    console.log(`GitHub Link: ${githubLink}`);
    console.log(`Message: ${message}`);
    console.log(`Score: ${score}`);

    // Tạo dòng mới để thêm vào bảng
    const newEntry = `| ${score} | [<img src="${issue.author.avatarUrl}" alt="${issue.author.login}" width="24" />  ${name}](${githubLink}) | ${message} | ${new Date(issue.updatedAt).toLocaleString('en-US', { timeZone: 'Asia/Ho_Chi_Minh' })} |\n`;

    const fileSystem = require('fs');
    const readmePath = 'README.md';
    let readme = fileSystem.readFileSync(readmePath, 'utf8');

    // Tìm và giữ nguyên header và footer của bảng
    const leaderboardSection = /<!-- Leaderboard -->[\s\S]*?<!-- \/Leaderboard -->/.exec(readme);

    if (leaderboardSection) {
        // Tìm vị trí của tiêu đề và dòng phân cách trong bảng
        const headerMatch = /(\| Score \| Player \| Message \| Date \|\n\|-------\|--------\|---------\|------\|)/.exec(leaderboardSection[0]);
        
        if (headerMatch) {
            // Chèn newEntry ngay dưới tiêu đề
            const updatedContent = leaderboardSection[0].replace(headerMatch[0], `${headerMatch[0]}\n${newEntry}`);
            
            // Thay thế toàn bộ leaderboard section trong README.md
            readme = readme.replace(leaderboardSection[0], updatedContent);
            fileSystem.writeFileSync(readmePath, readme, 'utf8');
            console.log('README.md updated successfully.');
        }
    }
};
