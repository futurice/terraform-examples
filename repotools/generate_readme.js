const fs = require("fs");
const { Transform, PassThrough } = require('stream');
const glob = require('glob');


function directory(path) {
  try {return path.match(/^(.*)\/_header_\/.*$/)[1]} catch {};
  return path.match(/(?<dir>.*)\/[^/]*/)[1];
}

const hclResourceRegex = /resource\s+"([^"]*)"/g

class AddSection extends Transform {
  constructor(options) {
    super(options);
    this.files = options.files;
    this.source = options.source;
  }
  _transform(data, encoding, callback) {
    if (this.source != "_header_/README.md") {
      const link = directory(this.source);
      this.push(`\n# [${link}](${link})\n`);
    }
        
    this.push(data);

    if (this.source == "_header_/README.md") {
      var work = Promise.resolve();
      this.push("\n## Directory layout\n")
      // Generate ToC
      this.files.map(file => {
        if (file.indexOf("node_modules") >= 0) return;
        const link = directory(file);
        if (link == "_header_") return;
        // Add resources used in Terraform recipe
        work = work.then(() => new Promise( (resolve) => {

          const level = (link.match(/\//g) || []).length;
          const indentation = new Array(level * 2 + 1).join(" ")
  
          this.push(`\n${indentation}- [${link}](${link})`); 
          console.log("glob")
          glob(link + '/*.tf', (err, tffiles) => {
            tffiles.map((file) => {
              const str = fs.readFileSync(file);
              let resources = [...str.toString().matchAll(hclResourceRegex)].map(
                match => match[1]
              ).sort();
              this.push(`\n${indentation}  - [${file}](${file}) uses:`);
              new Set(resources).forEach(resource => {
                this.push(`\n${indentation}    - resource ${resource}`);
              })
              console.log("resources: " + resources)
            });
            console.log("resolve glob")
            resolve();
          });
        }));
      });
      work.then(() => {
        console.log("finish work")
        this.push("\n\n");
        callback();
      })
    } else {
      this.push("\n\n");
      callback();
    }

  }
}

// BUGGY
// Convert
//  ![test1](./myImage1.png)
// to
//  ![image](/download/attachments/37064693/myImage1.png)
class RebaseImages extends Transform {
  constructor(options) {
    super(options);
  }
  _transform(data, encoding, callback) {
    const pattern = /!\[.+\]\(\.(\/.+\.png)\)/g;
    const replace = "![image](/download/attachments/37064693$1)";

    const newData = data.toString()
      .replace(pattern, replace);

    this.push(newData);

    callback();
  }
}

// NOTE SURE IF THIS WORKS
// Convert
//  [a b c](./b.md)
// to
//  [a b c](#doc-abc)
class ConvertLinksToAnchors extends Transform {
  constructor(options) {
    super(options);
  }
  _transform(data, encoding, callback) {
    const pattern = /\[(.+)\]\(\.\/(.+\.md)\)/g;

    const newData = data.toString()
      .replace(pattern, (m, p1, p2) => {
        const anchor = p1.replace(/\s/g, "");
        return `[${p1}](#doc-${anchor})`;
      });

    this.push(newData);

    callback();
  }
}


glob('*/**/*.md', (err, files) => {
    const outPath = "./README.md";
    const output = fs.createWriteStream(outPath);

    var work = Promise.resolve();
    // Add each section
    files.map(file => {
        if (file.indexOf("node_modules") >= 0) return;
        work = work.then(() => new Promise( (resolve) => {
            console.log(file);
            fs.createReadStream(file)
              .pipe(new AddSection({
                source: file,
                files: files
              }))
              .pipe(new RebaseImages())
              .pipe(new ConvertLinksToAnchors())
              .on("finish", (err) => resolve())
              .pipe(output, {end: false})
        }));
    });
});
