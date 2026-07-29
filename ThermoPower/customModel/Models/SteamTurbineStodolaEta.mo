within ThermoPower.customModel.Models;

model SteamTurbineStodolaEta
  "Modified ThermoPower.Water.SteamTurbineStodola"
  extends ThermoPower.Water.BaseClasses.SteamTurbineBase;
  parameter SI.PerUnit eta_iso_nom=0.92 "Nominal isentropic efficiency";
  parameter SI.Area Kt "Kt coefficient of Stodola's law";
  Medium.Density rho "Inlet density";
  
  Medium.SaturationProperties sat_out "Outlet Saturation properties";
  Medium.SpecificEnthalpy hl_out "Outlet Specific enthalpy of saturated liquid";
  Medium.SpecificEnthalpy hv_out "Outlet Specific enthalpy of saturated steam";
  Medium.MassFraction xout "Outlet steam quality";
  
  Medium.SaturationProperties sat_in "Inlet Saturation properties";
  Medium.SpecificEnthalpy hl_in "Inlet enthalpy of saturated liquid";
  Medium.SpecificEnthalpy hv_in "Inlet enthalpy of saturated steam";
  Medium.MassFraction xin "Inlet steam quality";
  
  parameter Boolean useWetnessCorrection = false "Apply Baumann's rule for isentropic eff. correction";
  parameter Boolean useMflowCorrection = false "Apply mass flow rate law for isentropic eff. correction";
  Real r_mflow "0~1 cliped mass flow ratio";
  Real f_wetness "Wetness correction factor";
  Real f_mflow "Mass flow rate law correction factor";
  
equation
  rho =  Medium.density(steamState_in);
  w = homotopy(Kt*theta*sqrt(pin*rho)*ThermoPower.Functions.sqrtReg(1 - (1/PR)^2),
               theta*wnom/pnom*pin) "Stodola's law";
  
  sat_out.psat = pout;
  sat_out.Tsat = Medium.saturationTemperature(pout);
  hl_out = Medium.bubbleEnthalpy(sat_out);
  hv_out = Medium.dewEnthalpy(sat_out);
  xout = if hout<=hl_out then 0 else if hout>=hv_out then 1 else (hout-hl_out)/(hv_out-hl_out);
  
  sat_in.psat = pin;
  sat_in.Tsat = Medium.saturationTemperature(pin);
  hl_in = Medium.bubbleEnthalpy(sat_in);
  hv_in = Medium.dewEnthalpy(sat_in);
  xin = if hin<=hl_in then 0 else if hin>=hv_in then 1 else (hin-hl_in)/(hv_in-hl_in);
  
  f_wetness = if useWetnessCorrection then (1-(1-(xin+xout)/2)) else 1 "Baumann's rule with unity coefficient";
  r_mflow = noEvent(min(1.0-Modelica.Constants.small, max(0.0, w/wnom))) "To prevent negative^1.4 during initial calculations";
  f_mflow = if useMflowCorrection then (1-0.14*(1-r_mflow)^1.4) else 1 "Empirical law, from 'Dynamic modelling and control of a Small Modular Reactor in load following by cogeneration mode'";
  eta_iso = eta_iso_nom*f_wetness*f_mflow "Final isentropic efficiency";
  annotation (Documentation(info="<html>
<p>This model is to include isentropic coefficient corrections during off-design conditions. Apply Baumann's rule for steam wetness correction (in/out average) with unity coefficient and empricial law for mass flow rate correction. Tested in SteamTurbineStodolaEta_test.mo.
</html>"));
end SteamTurbineStodolaEta;