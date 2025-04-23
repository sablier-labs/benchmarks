/**
 * Utility script to format large numbers in markdown files by adding thousand separators.
 * This is particularly useful for gas benchmark documentation where large numbers are common.
 */
const fs = require("node:fs/promises");

// Create a number formatter for US locale with thousand separators
const numberFormatter = new Intl.NumberFormat("en-US");

/**
 * Formats large numbers in a markdown file by adding thousand separators.
 * @param {string} filePath - Path to the markdown file to format
 */
async function format(filePath) {
  // Read the markdown file content
  const markdownContent = await fs.readFile(filePath, "utf8");

  // Replace large numbers with formatted versions that include thousand separators
  // Using a simpler regex that just matches numbers with 4 or more digits
  const formattedContent = markdownContent.replace(/\b\d{4,}\b/g, (match) => {
    return numberFormatter.format(Number.parseInt(match));
  });

  // Write the formatted content back to the file
  await fs.writeFile(filePath, formattedContent);
}

format("results/flow/sablier-flow.md");
format("results/lockup/sablier-batch-lockup.md");
format("results/lockup/sablier-lockup-dynamic.md");
format("results/lockup/sablier-lockup-linear.md");
format("results/lockup/sablier-lockup-tranched.md");
