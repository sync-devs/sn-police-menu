$(document).ready(function(){
    $(".police-container").hide();
    let openedMenu = false;
    window.addEventListener("message", function(event){
        let ev = event.data;

        switch (ev.act) {
            case "togMenu":
                openedMenu = !openedMenu;

                if (openedMenu) {
                    $(".police-container").fadeIn(800);
                    
                    $(".police-container section").empty();

                    Object.keys(ev.props).forEach(function(key) {
                        $(".police-container section").append('<div class="police-object" data-prop="' + key + '"> <div>' + ev.props[key] + '</div> </div>');
                    });
                } else {
                    $(".police-container").fadeOut(800);
                }

                break;
        }
    });

    $(".police-container").on("click", ".police-object", function(){
        openedMenu = false;
        $(".police-container").fadeOut(800);
        $.post(`http://${GetParentResourceName()}/polmenu:selProp`, JSON.stringify({prop: $(this).data("prop")}))
    });
});