---
pagetitle: List sortedness
bibliography: '../assets/bib/references.bib'
csl: '../assets/csl/iop-style.csl'
suppress-bibliography: false
link-citations: true
citations-hover: true
---

# Ranking rankings

Enter your list below.
The list elements can be separated by commas, spaces, or new lines.

<textarea id="list-input" cols=80 rows=4 autocorrect=off autocapitalize=off spellcheck=off>
</textarea>

Click "Calculate" to see how sorted the list is according to several different metrics. </br>I go into more details about the methods used to compute these scores below.

<b></b> <!-- This is load-bearing for some reason -->
<button id = "clear">Clear</button>
<button id = "calculate">Calculate</button>

<div id="answer-list" visibility="hidden">
<ul>
<li>Spearman correlation: <b id="spearman-ans"></b></li>
</ul>
</div>

<script>


function clearInput() {
    document.getElementById("list-input").value = ""
    document.getElementById("answer-list").style.visibility="hidden"
}

document.getElementById("clear").addEventListener("click", clearInput)

function sortperm(arr) {
    let len = arr.length;
    let indices = new Array(len)
    for (let i = 0; i < len; i++) {indices[i] = i}
    indices.sort((a, b) => arr[a] - arr[b])
    return indices
}

function spearman(rank) {
    let n = rank.length
    let sum_d_squared = 0;
    for (let i = 0; i < n; i++) {
        let d = i - rank[i]
        sum_d_squared += d*d
    }

    let rho = 1 - 6 * sum_d_squared / (n * (n*n - 1))
    return rho
}

function toPercent(num) {
   return (Math.floor(num * 1000) / 10).toString() + "%" 
}

function onClick() {
    const input = document.getElementById("list-input")

    // Do nothing on empty list
    if (input.value === "") {
        return
    }

    // Form list
    let items = input.value.trim().split(/[\s,;]+/).map(Number)
    console.log("items: ", items)
    
    let rank = sortperm(items)
    console.log("rank: ", rank)
    console.log("spearman: ", spearman(rank))

    document.getElementById("answer-list").style.visibility="visible"


    document.getElementById("spearman-ans").innerHTML = toPercent(spearman(rank))
}

document.getElementById("calculate").addEventListener("click", onClick)

clearInput()

</script>
