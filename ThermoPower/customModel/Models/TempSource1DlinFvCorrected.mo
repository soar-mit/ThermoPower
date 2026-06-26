within ThermoPower.customModel.Models;

model TempSource1DlinFvCorrected
    "Replace existing model as it can't employ multiple instances due to linspaceExt.
    Instead, manual discretization is used here."
    extends Icons.HeatFlow;
    parameter Integer Nw = 1 "Number of volumes on the wall port";
    Thermal.DHTVolumes wall(final N = Nw) annotation(
      Placement(transformation(extent = {{-40, -40}, {40, -20}}, rotation = 0)));
    Modelica.Blocks.Interfaces.RealInput temperature_1 annotation(
      Placement(transformation(origin = {-40, 30}, extent = {{-20, -20}, {20, 20}}, rotation = 270), iconTransformation(origin = {-40, 30}, extent = {{-20, -20}, {20, 20}}, rotation = 270)));
    Modelica.Blocks.Interfaces.RealInput temperature_Nw annotation(
      Placement(transformation(origin = {40, 28}, extent = {{-20, -20}, {20, 20}}, rotation = 270)));
  equation
    if Nw == 1 then
      wall.T = {temperature_1};
    else
      wall.T = {temperature_1 + (temperature_Nw - temperature_1)*(i - 1)/(Nw - 1) for i in 1:Nw};
    end if;
    annotation(
      Documentation(info = "<HTML>
  <p>Model of an ideal 1D temperature source with a linear distribution. The values of the temperature at the two ends of the source are provided by the <tt>temperature_node1</tt> and <tt>temperature_nodeN</tt> signal connectors.
  </HTML>", revisions = "<html>
  <ul>
  <li><i>10 Jan 2004</i>
    by <a href=\"mailto:francesco.schiavo@polimi.it\">Francesco Schiavo</a>:<br>
       First release.</li>
  </ul>
  </html>
  "),
      Icon(graphics = {Text(textColor = {191, 95, 0}, extent = {{-100, -46}, {100, -72}}, textString = "%name"), Text(origin = {-82, 36}, extent = {{-26, 18}, {26, -18}}, textString = "T1"), Text(origin = {86, 36}, extent = {{-26, 18}, {26, -18}}, textString = "TN")}),
      Diagram(graphics));
end TempSource1DlinFvCorrected;
