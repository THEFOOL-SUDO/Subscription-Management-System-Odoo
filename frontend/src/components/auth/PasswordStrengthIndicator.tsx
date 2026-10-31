import React from "react";
import { Check, X } from "lucide-react";
import { passwordRegexRules } from "@/lib/validations";

interface Props {
  password: string;
}

export const PasswordStrengthIndicator: React.FC<Props> = ({ password }) => {
  const criteria = [
    { label: "More than 8 characters", met: passwordRegexRules.minLength(password) },
    { label: "At least one uppercase letter (A-Z)", met: passwordRegexRules.hasUpper(password) },
    { label: "At least one lowercase letter (a-z)", met: passwordRegexRules.hasLower(password) },
    { label: "At least one number (0-9)", met: passwordRegexRules.hasNumber(password) },
    { label: "At least one special character (!@#$...)", met: passwordRegexRules.hasSpecial(password) },
  ];

  const metCount = criteria.filter((c) => c.met).length;
  const strengthPercentage = (metCount / criteria.length) * 100;

  const getBarColor = () => {
    if (metCount <= 2) return "bg-rose-500";
    if (metCount <= 4) return "bg-amber-500";
    return "bg-emerald-500";
  };

  return (
    <div className="mt-2 space-y-2 text-xs">
      {/* Progress Bar */}
      <div className="h-1.5 w-full bg-slate-100 rounded-full overflow-hidden">
        <div
          className={`h-full transition-all duration-300 ${getBarColor()}`}
          style={{ width: `${strengthPercentage}%` }}
        />
      </div>

      {/* Criteria Checklist */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-1.5 pt-1">
        {criteria.map((item, idx) => (
          <div
            key={idx}
            className={`flex items-center gap-1.5 ${
              item.met ? "text-emerald-700 font-medium" : "text-slate-400"
            }`}
          >
            {item.met ? (
              <Check className="w-3.5 h-3.5 text-emerald-600 shrink-0" />
            ) : (
              <X className="w-3.5 h-3.5 text-slate-300 shrink-0" />
            )}
            <span>{item.label}</span>
          </div>
        ))}
      </div>
    </div>
  );
};
