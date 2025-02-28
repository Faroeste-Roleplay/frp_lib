
const mergeArrData = (arr, data) => {
    return [ ...arr, ...data];
}
exports("mergeArrData", mergeArrData)

const mergeObjectData = (obj, data) => {
    return { ...obj, ...data }
}
exports("mergeObjectData", mergeObjectData)


const camelToSnakeCase = str => str.replace(/[A-Z]/g, (letter, index) => { return index == 0 ? letter.toLowerCase() : '_'+ letter.toLowerCase();});;
exports('camelToSnakeCase', camelToSnakeCase)

// HELLO WORLD -> Hello World
function titleCaseWord(mySentence)
{
    const words = mySentence.split(' ');

    for (let i = 0; i < words.length; i++)
    {
        words[i] = words[i][0].toUpperCase() + words[i].substr(1);
    }

    return words.join(' ');
}
exports('titleCaseWord', titleCaseWord)


// HELLO_WORLD -> helloWorld
const snakeToCamel = (str) => str.toLowerCase().replace( /([-_]\w)/g, g => g[ 1 ].toUpperCase() );
exports('snakeToCamel', snakeToCamel)

// HELLO_WORLD -> HelloWorld
const snakeToPascal = (str) =>
{
    let camelCase = snakeToCamel( str );
    let pascalCase = camelCase[ 0 ].toUpperCase() + camelCase.substr( 1 );
    return pascalCase;
}
exports('snakeToPascal', snakeToPascal)


exports('getPedComponentAtIndex', (categoryComponent) =>
    {
        const arrayBuffer = new ArrayBuffer(256 * 4);
        const dataView = new DataView(arrayBuffer);
    
        dataView.setUint32(0, 127, true);
    
        const arrayBuffer2 = new ArrayBuffer(256 * 4);
        const dataView2 = new DataView(arrayBuffer2);
    
        dataView2.setUint32(0, 127, true);
    
        for (let i = 0; i < 40; i++)
        {
            const r = Citizen.invokeNative("0x77BA37622E22023B", PlayerPedId(), i, false, dataView, dataView2, Citizen.returnResultAnyway())
            
            // const arrayOut = new Int32Array(arrayBuffer);
            // const arrayOut2 = new Int32Array(arrayBuffer2);        
    
            const isMale = IsPedMale(PlayerPedId()) ? 0 : 1;
    
            let category =  Citizen.invokeNative("0x5FF9A878C3D115B8", r, isMale, true)
    
            console.log('category', category, GetHashKey(categoryComponent), category == GetHashKey(categoryComponent));
    
            if (category == GetHashKey(categoryComponent))
            {
                return r
            }        
        }
    })


exports('getPedComponentAtIndexCategory', (categoryHash, pedOverride) => 
{
    const arrayBuffer = new ArrayBuffer(256 * 4);
    const dataView = new DataView(arrayBuffer);

    dataView.setUint32(0, 127, true);

    const arrayBuffer2 = new ArrayBuffer(256 * 4);
    const dataView2 = new DataView(arrayBuffer2);

    dataView2.setUint32(0, 127, true);

    const ped = pedOverride ?? PlayerPedId();

    for (let i = 0; i < 40; i++)
    {
        let r = Citizen.invokeNative("0x77BA37622E22023B", ped, i, false, dataView, dataView2, Citizen.returnResultAnyway())        

        r = r >>> 0;
        // const arrayOut = new Int32Array(arrayBuffer);
        // const arrayOut2 = new Int32Array(arrayBuffer2);        

        const isMale = IsPedMale(ped) ? 0 : 1;

        let category =  Citizen.invokeNative("0x5FF9A878C3D115B8", r, isMale, true)
        
        for (let i = 0; i < categoryHash.length; i++ )
        {
            let cHash = categoryHash[i]
            
            if (category == cHash)
            {
                return r
            }        
        }
    }
});