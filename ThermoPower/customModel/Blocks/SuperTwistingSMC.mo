within ThermoPower.customModel.Blocks;

block SuperTwistingSMC "Super-twisting sliding mode controller"
  extends Modelica.Blocks.Interfaces.SVcontrol;
  // provides u_s, u_m, y ports
  parameter Real c = 1.0 "Sliding surface coefficient";
  parameter Real lambda "|s|^0.5 gain";
  parameter Real alpha "Super-twisting integral gain";
  parameter Real T_C = 0.05 "Derivative filter time constant";
  parameter Real w_start = 0 "Initial super-twisting state";
  parameter Real phi_lambda(min=1e-8) = 1 "tanh boundary layer width for |s|^0.5 gain";
  parameter Real phi_alpha(min=1e-8) = phi_lambda "tanh boundary layer width for integral gain";
  //================= error =================
  Modelica.Blocks.Math.Feedback err "u_s - u_m" annotation(
    Placement(transformation(extent = {{-90, -10}, {-70, 10}})));
  //================= sliding surface  s = c*err + edot_filt =================
  Modelica.Blocks.Math.Gain gain_c(k = c) annotation(
    Placement(transformation(origin = {-22, 6}, extent = {{-42, 14}, {-28, 28}})));
  Modelica.Blocks.Continuous.Derivative derivative(k = 1, T = T_C, initType = Modelica.Blocks.Types.Init.InitialState, x_start = 0) "filtered derivative  s/(T_C s + 1)" annotation(
    Placement(transformation(origin = {-22, 4}, extent = {{-42, -28}, {-28, -14}})));
  Modelica.Blocks.Math.Add add_s annotation(
    Placement(transformation(origin = {-30, 5}, extent = {{-14, -7}, {0, 7}})));
  //================= continuous term  lambda*sqrt(|s|)*sign(s) =================
  Modelica.Blocks.Math.Abs abs_s annotation(
    Placement(transformation(origin = {-34, -1}, extent = {{14, 21}, {28, 35}})));
  Modelica.Blocks.Math.Sqrt sqrt_s annotation(
    Placement(transformation(origin = {-33, -1}, extent = {{35, 21}, {49, 35}})));
  Modelica.Blocks.Math.Product prod_cont annotation(
    Placement(transformation(origin = {-32, -1.5}, extent = {{56, 10.5}, {70, 24.5}})));
  Modelica.Blocks.Math.Gain gain_lambda(k = lambda) annotation(
    Placement(transformation(origin = {-31, -1.5}, extent = {{77, 10.5}, {91, 24.5}})));
  //================= integral term  w = int(alpha*sign(s)) =================
  Modelica.Blocks.Math.Gain gain_alpha(k = alpha) annotation(
    Placement(transformation(origin = {-15, 14}, extent = {{35, -28}, {49, -14}})));
  Modelica.Blocks.Continuous.Integrator integ_w(k = 1, initType = Modelica.Blocks.Types.Init.InitialState, y_start = w_start) annotation(
    Placement(transformation(origin = {-12, 14}, extent = {{56, -28}, {70, -14}})));
  //================= output sum  y = cont + w =================
  Modelica.Blocks.Math.Add add_U annotation(
    Placement(transformation(origin = {-26, -1}, extent = {{98, -7}, {112, 7}})));
  Modelica.Blocks.Math.Tanh tanh_lambda annotation(
    Placement(transformation(origin = {-7, -37}, extent = {{-7, -7}, {7, 7}})));
  Modelica.Blocks.Math.Gain gain_phi_lambda(k = 1/phi_lambda) annotation(
    Placement(transformation(origin = {4, -58}, extent = {{-42, 14}, {-28, 28}})));
  Modelica.Blocks.Math.Gain gain_phi_alpha(k = 1/phi_alpha) annotation(
    Placement(transformation(origin = {4, -80}, extent = {{-42, 14}, {-28, 28}})));
  Modelica.Blocks.Math.Tanh tanh_alpha annotation(
    Placement(transformation(origin = {-9, -59}, extent = {{-7, -7}, {7, 7}})));
equation
//-------- error --------
  connect(u_s, err.u1) annotation(
    Line(points = {{-120, 0}, {-88, 0}}, color = {0, 0, 127}));
  connect(u_m, err.u2) annotation(
    Line(points = {{0, -120}, {0, -80}, {-80, -80}, {-80, -8}}, color = {0, 0, 127}));
//-------- continuous term --------
  connect(abs_s.y, sqrt_s.u) annotation(
    Line(points = {{-5, 27}, {1, 27}}, color = {0, 0, 127}));
  connect(prod_cont.y, gain_lambda.u) annotation(
    Line(points = {{39, 16}, {45, 16}}, color = {0, 0, 127}));
//-------- integral term --------
//-------- output sum --------
  connect(err.y, derivative.u) annotation(
    Line(points = {{-70, 0}, {-70, -16}, {-66, -16}}, color = {0, 0, 127}));
  connect(err.y, gain_c.u) annotation(
    Line(points = {{-70, 0}, {-70, 28}, {-66, 28}}, color = {0, 0, 127}));
  connect(derivative.y, add_s.u2) annotation(
    Line(points = {{-50, -16}, {-46, -16}, {-46, 0}}, color = {0, 0, 127}));
  connect(gain_c.y, add_s.u1) annotation(
    Line(points = {{-50, 28}, {-46, 28}, {-46, 10}}, color = {0, 0, 127}));
  connect(add_s.y, abs_s.u) annotation(
    Line(points = {{-30, 6}, {-26, 6}, {-26, 28}, {-22, 28}}, color = {0, 0, 127}));
  connect(sqrt_s.y, prod_cont.u1) annotation(
    Line(points = {{16, 28}, {18, 28}, {18, 20}, {22, 20}}, color = {0, 0, 127}));
  connect(gain_lambda.y, add_U.u1) annotation(
    Line(points = {{60, 16}, {64, 16}, {64, 4}, {70, 4}}, color = {0, 0, 127}));
  connect(add_U.y, y) annotation(
    Line(points = {{88.7, -1}, {112.7, -1}}, color = {0, 0, 127}));
  connect(integ_w.y, add_U.u2) annotation(
    Line(points = {{58, -6}, {70, -6}}, color = {0, 0, 127}));
  connect(integ_w.u, gain_alpha.y) annotation(
    Line(points = {{42, -6}, {34, -6}}, color = {0, 0, 127}));
  connect(add_s.y, gain_phi_lambda.u) annotation(
    Line(points = {{-30, 6}, {-26, 6}, {-26, -20}, {-46, -20}, {-46, -37}, {-39, -37}}, color = {0, 0, 127}));
  connect(gain_phi_lambda.y, tanh_lambda.u) annotation(
    Line(points = {{-24, -36}, {-16, -36}}, color = {0, 0, 127}));
  connect(tanh_lambda.y, prod_cont.u2) annotation(
    Line(points = {{0, -36}, {10, -36}, {10, 12}, {22, 12}}, color = {0, 0, 127}));
  connect(add_s.y, gain_phi_alpha.u) annotation(
    Line(points = {{-30, 6}, {-26, 6}, {-26, -20}, {-46, -20}, {-46, -58}, {-40, -58}}, color = {0, 0, 127}));
  connect(gain_phi_alpha.y, tanh_alpha.u) annotation(
    Line(points = {{-24, -58}, {-18, -58}}, color = {0, 0, 127}));
  connect(tanh_alpha.y, gain_alpha.u) annotation(
    Line(points = {{-2, -58}, {14, -58}, {14, -6}, {18, -6}}, color = {0, 0, 127}));
  annotation(
    Diagram(coordinateSystem(extent = {{-140, 40}, {140, -140}})),
    Icon(coordinateSystem(preserveAspectRatio = true), graphics = {Rectangle(extent = {{-100, -100}, {100, 100}}, lineColor = {0, 0, 127}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-80, 40}, {80, -40}}, textString = "ST-SMC"), Text(extent = {{-150, 150}, {150, 110}}, textString = "%name", lineColor = {0, 0, 255})}));
end SuperTwistingSMC;