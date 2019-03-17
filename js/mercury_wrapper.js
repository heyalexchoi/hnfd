import Mercury from "@postlight/mercury-parser";

export class MercuryParser {
    static parse(url) {
        Mercury.parse(url).then(result => {
            console.log(result)
            return result;
        });
    }
};


const url="https://trackchanges.postlight.com/building-awesome-cms-f034344d8ed";
MercuryParser.parse(url).then(result => console.log(result));
