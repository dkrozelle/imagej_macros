


macro "go" {

lenses     = newArray(
	"axiovert 200M 100X-oil",
	"axiovert 200M 63X-oil",
	"axiovert 200M 40X-air",
	"axiovert 200M 20X-air",
	"axiovert 200M 10X-air",
	"axiovert 200M 2.5X-air",
	"lsm 710 63x-oil" );

//pixel width in micron
pixel_size = newArray(
	"0.0625",
	"0.0990",
	"0.1572",
	"0.3121",
	"0.6258",
	"2.396",

    	"0.13");

Dialog.create("Configure Lens");
Dialog.addChoice("Lens",lenses,lenses[1]);
Dialog.show();

lens  = Dialog.getChoice();

for (i=0; i<lenses.length; i++){
	if(lenses[i]==lens){
		scale = pixel_size[i];

		}
	}

run("Set Scale...", "distance=1 known="+scale+" pixel=1 unit=micron");
run("Add Scale Bar ");
}