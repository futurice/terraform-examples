const fs = require("fs");
const { Transform, PassThrough } = require('stream');
const glob = require('glob');

function concatStreams(streams) {
  let pass = new PassThrough();
  let waiting = streams.length;
  for (let stream of streams) {
      pass = stream.pipe(pass, {end: false});
      stream.once('end', () => waiting-- === 0 && pass.emit('end'));
  }
  return pass;
}

class AddEndOfLine extends Transform {
  constructor(options) {
    super(options);
  }
  _transform(data, encoding, callback) {
    this.push(data);

    this.push("\n\n");

    callback();
  }
}

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
glob('*/**/*.md', (err, inPaths) => {
    const outPath = "./README.md";
    inPaths.map(x => console.log(x));
    const inputs = inPaths.map(x => fs.createReadStream(x));
    const output = fs.createWriteStream(outPath);
    
    concatStreams(inputs)
      .pipe(new AddEndOfLine())
      .pipe(new RebaseImages())
      .pipe(new ConvertLinksToAnchors())
      .pipe(output)
      .on("finish", function () {
        console.log("Done merging!");
      });
});
