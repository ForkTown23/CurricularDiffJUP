async function populate() {
    const request_destination = "./../results.json"
    const request = new Request(request_destination)
    const response = await fetch(request)
    const results = await response.json()

    document.getElementById("JSON").innerHTML = JSON.stringify(results, undefined, 2)
    console.log("HELLO WORLD")
}

//document.addEventListener("DOMContentLoaded", console.log(datafile.MC31));