within ThermoPower.customModel.Examples;

model RadialConduction1D_test
  "Test for RadialConduction1D and TempSource1DlinFvCorrected models"
  ThermoPower.customModel.RadialConduction1D Case1(Nw = 10, Nr = 5, L = 1, rint = 16e-3, rext = 20e-3, rhomcm = 8000*500, lambda = 16, nodeDistribution = ThermoPower.Choices.CylinderFourier.NodeDistribution.uniform, Tstartbar (displayUnit = "K")= 400, useHeatGen = false) annotation(
    Placement(transformation(origin = {-18, 60}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  Modelica.Blocks.Sources.Constant const(k = 300) annotation(
    Placement(transformation(origin = {-74, 50}, extent = {{-8, -8}, {8, 8}})));
  Modelica.Blocks.Sources.Constant const1(k = 500) annotation(
    Placement(transformation(origin = {-74, 82}, extent = {{-8, -8}, {8, 8}})));
  inner System system(initOpt = ThermoPower.Choices.Init.Options.fixedState) annotation(
    Placement(transformation(origin = {-116, 84}, extent = {{-10, -10}, {10, 10}})));
  Thermal.HeatSource1DFV heatSource1DFV(Nw = 10) annotation(
    Placement(transformation(origin = {8, 60}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Blocks.Sources.Constant const11(k = 1000) annotation(
    Placement(transformation(origin = {32, 60}, extent = {{8, -8}, {-8, 8}})));
  ThermoPower.customModel.RadialConduction1D Case2(L = 1, Nr = 5, Nw = 10, Tstartbar (displayUnit = "K")= 400, lambda = 16, nodeDistribution = Choices.CylinderFourier.NodeDistribution.uniform, rext = 20e-3, rhomcm = 8000*500, rint = 0, useHeatGen = true, heatGenValue = 10000000) annotation(
    Placement(transformation(origin = {-122, -10}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  Modelica.Blocks.Sources.Constant const2(k = 300) annotation(
    Placement(transformation(origin = {-70, -32}, extent = {{8, -8}, {-8, 8}})));
  Modelica.Blocks.Sources.Constant const21(k = 500) annotation(
    Placement(transformation(origin = {-68, 8}, extent = {{8, -8}, {-8, 8}})));
  customModel.TempSource1DlinFvCorrected tempSource1DlinFvCorrected(Nw = 10) annotation(
    Placement(transformation(origin = {-38, 60}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  ThermoPower.customModel.TempSource1DlinFvCorrected tempSource1DlinFvCorrected1(Nw = 10) annotation(
    Placement(transformation(origin = {-98, -10}, extent = {{10, -10}, {-10, 10}}, rotation = -90)));
ThermoPower.customModel.RadialConduction1D Case3(L = 1, Nr = 5, Nw = 10, Tstartbar (displayUnit = "K")= 400, lambda = 16, nodeDistribution = Choices.CylinderFourier.NodeDistribution.uniform, rext = 20e-3, rhomcm = 8000*500, rint = 0, useHeatGen = true, useExternalHeatGen = true) annotation(
    Placement(transformation(origin = {10, -8}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
Modelica.Blocks.Sources.Constant const22(k = 300) annotation(
    Placement(transformation(origin = {64, -30}, extent = {{8, -8}, {-8, 8}})));
Modelica.Blocks.Sources.Constant const211(k = 500) annotation(
    Placement(transformation(origin = {64, 10}, extent = {{8, -8}, {-8, 8}})));
ThermoPower.customModel.TempSource1DlinFvCorrected tempSource1DlinFvCorrected11(Nw = 10) annotation(
    Placement(transformation(origin = {34, -8}, extent = {{10, -10}, {-10, 10}}, rotation = -90)));
Modelica.Blocks.Sources.Constant const12(k = 1.2566e+04) annotation(
    Placement(transformation(origin = {-14, -28}, extent = {{-8, -8}, {8, 8}})));
equation
  connect(heatSource1DFV.wall, Case1.ext) annotation(
    Line(points = {{5, 60}, {-16, 60}}, color = {255, 127, 0}));
  connect(const11.y, heatSource1DFV.power) annotation(
    Line(points = {{23.2, 60}, {12.4, 60}}, color = {0, 0, 127}));
  connect(const.y, tempSource1DlinFvCorrected.temperature_1) annotation(
    Line(points = {{-65.2, 50}, {-53.2, 50}, {-53.2, 56}, {-40.2, 56}}, color = {0, 0, 127}));
  connect(const1.y, tempSource1DlinFvCorrected.temperature_Nw) annotation(
    Line(points = {{-65.2, 82}, {-53.2, 82}, {-53.2, 64}, {-40.2, 64}}, color = {0, 0, 127}));
  connect(const2.y, tempSource1DlinFvCorrected1.temperature_1) annotation(
    Line(points = {{-78.8, -32}, {-88.8, -32}, {-88.8, -14}, {-95, -14}}, color = {0, 0, 127}));
  connect(const21.y, tempSource1DlinFvCorrected1.temperature_Nw) annotation(
    Line(points = {{-76.8, 8}, {-95, 8}, {-95, -6}}, color = {0, 0, 127}));
  connect(tempSource1DlinFvCorrected1.wall, Case2.ext) annotation(
    Line(points = {{-101, -10}, {-119, -10}}, color = {255, 127, 0}));
  connect(tempSource1DlinFvCorrected.wall, Case1.int) annotation(
    Line(points = {{-35, 60}, {-20, 60}}, color = {255, 127, 0}));
  connect(const22.y, tempSource1DlinFvCorrected11.temperature_1) annotation(
    Line(points = {{55, -30}, {43.2, -30}, {43.2, -12}, {37, -12}}, color = {0, 0, 127}));
  connect(const211.y, tempSource1DlinFvCorrected11.temperature_Nw) annotation(
    Line(points = {{55.2, 10}, {37, 10}, {37, -4}}, color = {0, 0, 127}));
  connect(tempSource1DlinFvCorrected11.wall, Case3.ext) annotation(
    Line(points = {{31, -8}, {13, -8}}, color = {255, 127, 0}));
connect(const12.y, Case3.heatGenInput) annotation(
    Line(points = {{-5.2, -28}, {8.8, -28}, {8.8, -18}, {9.8, -18}}, color = {0, 0, 127}));
annotation(
    Diagram(coordinateSystem(extent = {{-140, 100}, {100, -100}}), graphics = {Text(origin = {-15, 84}, extent = {{-7, 6}, {7, -6}}, textString = "Case1"), Text(origin = {-101, 20}, extent = {{-7, 6}, {7, -6}}, textString = "Case2"), Text(origin = {23, 20}, extent = {{-7, 6}, {7, -6}}, textString = "Case3")}),
  experiment(StartTime = 0, StopTime = 300, Tolerance = 1e-06, Interval = 0.6),
  Documentation(info = "<HTML>
<p>Case1: temp. distribution at inner and heat source at outer with existing model.
  <p>Case2: Adiabatic inner and temp. distribution at outer with internal heat gen. value.
  <p>Case3: Adiabatic inner and temp. distribution at outer with external heat input.
  <p>Case2 and 3 should give same results
</ul>
</HTML>"));
end RadialConduction1D_test;