var css = `
body {
	zoom: 2; /* TODO: use parameter */
	text-align: left;
	overflow: hidden;
}
body > *:not(.cards),
section > h1,
section > h2,
section > h3,
section > h4,
section > h5,
section > h6,
.cards > h1,
.cards > h2,
.cards > h3,
.cards > h4,
.cards > h5,
.cards > h6 {
	display: none;
}
.card {
	margin: 0;
}
`;
window.addEventListener("load", ()=> {
	var style = document.createElement('style');
	style.type = 'text/css';
	style.appendChild(document.createTextNode(css));
	document.head.appendChild(style);
});
