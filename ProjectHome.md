DSPF is a Plugin Framework for Delphi.DSPF is designed for the Applicaion contains lots of DLLs.<br>

DSPF can serialize and deserialize plugins with JSON string.<br>

With DSPF, there are some Limitiation:<br>
1.Each DLL must supply a IPlugInModule Interface, and IPlugInModule contains several IPlugInFactory<br>
2.IPlugInFactory can only Create or Destroy one type of PlugIn.<br>
3.Each PlugIn must support IPlugIn interface.<br>