// generator("next");
function generator (property) {
  return function () {
    if (page[property]) {
      window.location = page[property]
    };
  };
};

window.addEvent("domready", function (event) {
  window.addEvent("click", generator("next"));

  window.addEvent("keydown", function (event) {
    switch (event.key) {
    case "right":
      fn = generator("next")
      fn(); break;
    case "enter":
      fn = generator("next")
      fn(); break;
    case "left":
      fn = generator("previous")
      fn(); break;
    };
  });
});
