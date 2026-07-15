within ThermoPower.customModel.Examples;

model SuperTwistingSMC_test "Mass-spring-damper (equations) + super-twisting SMC"
  parameter Real M = 1;
  parameter Real D = 0.1;
  parameter Real K = 1;
  // Plant states as plain variables
  Real x1(start = 1, fixed = true) "position";
  Real x2(start = 0, fixed = true) "velocity";
  ThermoPower.customModel.Blocks.SuperTwistingSMC STC(c = 1, lambda = 2, alpha = 0.2, T_C = 0.05)  annotation(
    Placement(transformation(extent = {{-20, -10}, {0, 10}})));
  Modelica.Blocks.Sources.Constant ref(k = 0) annotation(
    Placement(transformation(extent = {{-60, -10}, {-40, 10}})));
equation
// ----- connect only the block-to-block ports -----
  connect(ref.y, STC.u_s) annotation(
    Line(points = {{-39, 0}, {-22, 0}}, color = {0, 0, 127}));
// ----- plant as plain equations -----
  STC.u_m = x1;
  der(x1) = x2;
  der(x2) = (STC.y - D*x2 - K*x1)/M;
  annotation(
    experiment(StartTime = 0, StopTime = 10, Tolerance = 1e-06, Interval = 0.001),
    Diagram(coordinateSystem(extent = {{-80, -40}, {40, 40}})),
    Documentation(info = "<html>
<p>Verification test for SuperTwistingSMC model based on MATLAB example. Shows oscillatory behavior due to tanh() instead of sign().
To reproduce MATLAB results, change tanh block to sign block in SMC model</p>
</html>"));
end SuperTwistingSMC_test;