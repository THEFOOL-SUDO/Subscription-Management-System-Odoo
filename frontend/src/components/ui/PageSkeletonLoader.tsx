import React from "react";

export const PageSkeletonLoader: React.FC = () => {
  return (
    <div className="space-y-6 animate-pulse">
      {/* Header Skeleton */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-2">
        <div className="space-y-2">
          <div className="h-7 w-48 bg-slate-200 rounded-md" />
          <div className="h-4 w-72 bg-slate-100 rounded-md" />
        </div>
        <div className="h-9 w-32 bg-slate-200 rounded-lg" />
      </div>

      {/* KPI Cards Skeleton */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {[1, 2, 3, 4].map((i) => (
          <div key={i} className="p-5 rounded-xl border border-slate-200 bg-white space-y-3">
            <div className="flex justify-between items-center">
              <div className="h-3 w-20 bg-slate-100 rounded" />
              <div className="h-8 w-8 rounded-lg bg-slate-100" />
            </div>
            <div className="h-8 w-28 bg-slate-200 rounded-md" />
            <div className="h-3 w-36 bg-slate-100 rounded" />
          </div>
        ))}
      </div>

      {/* Table Skeleton */}
      <div className="rounded-xl border border-slate-200 bg-white p-5 space-y-4">
        <div className="flex justify-between items-center pb-2">
          <div className="h-8 w-64 bg-slate-100 rounded-md" />
          <div className="h-8 w-24 bg-slate-100 rounded-md" />
        </div>
        <div className="space-y-3">
          {[1, 2, 3, 4, 5].map((row) => (
            <div key={row} className="h-10 bg-slate-50 border border-slate-100 rounded-lg" />
          ))}
        </div>
      </div>
    </div>
  );
};

