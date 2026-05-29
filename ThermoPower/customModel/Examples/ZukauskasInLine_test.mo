within ThermoPower.customModel.Examples;

model ZukauskasInLine_test
  ThermoPower.Thermal.MetalTubeFV sg_wall(L = 30, Nt = 366, Nw = 30, Tstartbar = 673.15, lambda = 22, rext = 19.05e-3/2, rhomcm = 4000000, rint = 13.05e-3/2) annotation(
    Placement(transformation(origin = {0, 4}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  ThermoPower.Gas.Flow1DFV sg_primary(A = 3.06, Dhyd = 19.05e-3, FFtype = ThermoPower.Choices.Flow1D.FFtypes.Kfnom, redeclare model HeatTransfer = ThermoPower.customModel.ZukauskasInLineHTC(pt_OD = 1.5), L = 30, redeclare package Medium = Modelica.Media.IdealGases.SingleGases.He, N = 31, Nt = 1, Tstartbar = 1023.15, dpnom = 1e5, e = 0.00015, omega = 21.9, pstart(displayUnit = "MPa") = 6e6, wnom = 81.6, Kfnom = 27) annotation(
    Placement(transformation(origin = {-22, 4}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  ThermoPower.Gas.SourceMassFlow sourceMassFlow(redeclare package Medium = Modelica.Media.IdealGases.SingleGases.He, T = 1023.15, p0(displayUnit = "MPa") = 6e6, w0 = 81.6) annotation(
    Placement(transformation(origin = {-44, 28}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.Gas.SinkPressure sinkPressure(T = 598.15, p0(displayUnit = "MPa") = 6e6, redeclare package Medium = Modelica.Media.IdealGases.SingleGases.He) annotation(
    Placement(transformation(origin = {-44, -12}, extent = {{10, -10}, {-10, 10}})));
  Thermal.ConvHTFV convHTFV1(Nv = 30, G = 5000*3.14*0.01305*30*366)  annotation(
    Placement(transformation(origin = {14, 4}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  Thermal.TempSource1DFV tempSource1DFV(Nw = 30)  annotation(
    Placement(transformation(origin = {34, 4}, extent = {{10, -10}, {-10, 10}}, rotation = -90)));
  Modelica.Blocks.Sources.Constant const(k = 523)  annotation(
    Placement(transformation(origin = {58, 4}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
  inner ThermoPower.System system(allowFlowReversal = false, initOpt = ThermoPower.Choices.Init.Options.fixedState) annotation(
    Placement(transformation(origin = {-80, 72}, extent = {{-10, -10}, {10, 10}})));
equation
  connect(sourceMassFlow.flange, sg_primary.infl) annotation(
    Line(points = {{-34, 28}, {-22, 28}, {-22, 14}}, color = {159, 159, 223}));
  connect(sg_primary.outfl, sinkPressure.flange) annotation(
    Line(points = {{-22, -6}, {-22, -12}, {-34, -12}}, color = {159, 159, 223}));
  connect(convHTFV1.side1, sg_wall.int) annotation(
    Line(points = {{11, 4}, {3, 4}}, color = {255, 127, 0}));
  connect(tempSource1DFV.wall, convHTFV1.side2) annotation(
    Line(points = {{31, 4}, {17, 4}}, color = {255, 127, 0}));
  connect(const.y, tempSource1DFV.temperature) annotation(
    Line(points = {{47, 4}, {38, 4}}, color = {0, 0, 127}));
  connect(sg_wall.ext, sg_primary.wall) annotation(
    Line(points = {{-3, 4}, {-17, 4}}, color = {255, 127, 0}));
annotation(
    experiment(StartTime = 0, StopTime = 100, Tolerance = 1e-06, Interval = 0.2));
end ZukauskasInLine_test;