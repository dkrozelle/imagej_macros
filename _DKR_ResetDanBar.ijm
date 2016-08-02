
macro "go"{

title = 'DanBar'; // the ActionBar's title 
if (isOpen(title)) { 
js ='title="'+title+'";'+ 
'WindowManager.getFrame(title).dispose();'+ 
'WindowManager.removeWindow(WindowManager.getFrame(title));'; 
eval ('script',js); 
} 
run(" DanBar");
}