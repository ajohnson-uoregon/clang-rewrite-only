//===--- Index.cpp -----------------------------------------------*- C++-*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Index.h"
#include "Logger.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/Support/Error.h"
#include "llvm/Support/raw_ostream.h"

namespace clang {
namespace clangd {

llvm::raw_ostream &operator<<(llvm::raw_ostream &OS, RefKind K) {
  if (K == RefKind::Unknown)
    return OS << "Unknown";
  static const std::vector<const char *> Messages = {"Decl", "Def", "Ref"};
  bool VisitedOnce = false;
  for (unsigned I = 0; I < Messages.size(); ++I) {
    if (static_cast<uint8_t>(K) & 1u << I) {
      if (VisitedOnce)
        OS << ", ";
      OS << Messages[I];
      VisitedOnce = true;
    }
  }
  return OS;
}

llvm::raw_ostream &operator<<(llvm::raw_ostream &OS, const Ref &R) {
  return OS << R.Location << ":" << R.Kind;
}

void RefSlab::Builder::insert(const SymbolID &ID, const Ref &S) {
  auto &M = Refs[ID];
  M.push_back(S);
  M.back().Location.FileURI =
      UniqueStrings.save(M.back().Location.FileURI).data();
}

RefSlab RefSlab::Builder::build() && {
  // We can reuse the arena, as it only has unique strings and we need them all.
  // Reallocate refs on the arena to reduce waste and indirections when reading.
  std::vector<std::pair<SymbolID, llvm::ArrayRef<Ref>>> Result;
  Result.reserve(Refs.size());
  size_t NumRefs = 0;
  for (auto &Sym : Refs) {
    auto &SymRefs = Sym.second;
    llvm::sort(SymRefs);
    // FIXME: do we really need to dedup?
    SymRefs.erase(std::unique(SymRefs.begin(), SymRefs.end()), SymRefs.end());

    NumRefs += SymRefs.size();
    auto *Array = Arena.Allocate<Ref>(SymRefs.size());
    std::uninitialized_copy(SymRefs.begin(), SymRefs.end(), Array);
    Result.emplace_back(Sym.first, llvm::ArrayRef<Ref>(Array, SymRefs.size()));
  }
  return RefSlab(std::move(Result), std::move(Arena), NumRefs);
}

void SwapIndex::reset(std::unique_ptr<SymbolIndex> Index) {
  // Keep the old index alive, so we don't destroy it under lock (may be slow).
  std::shared_ptr<SymbolIndex> Pin;
  {
    std::lock_guard<std::mutex> Lock(Mutex);
    Pin = std::move(this->Index);
    this->Index = std::move(Index);
  }
}
std::shared_ptr<SymbolIndex> SwapIndex::snapshot() const {
  std::lock_guard<std::mutex> Lock(Mutex);
  return Index;
}

bool fromJSON(const llvm::json::Value &Parameters, FuzzyFindRequest &Request) {
  llvm::json::ObjectMapper O(Parameters);
  int64_t Limit;
  bool OK =
      O && O.map("Query", Request.Query) && O.map("Scopes", Request.Scopes) &&
      O.map("AnyScope", Request.AnyScope) && O.map("Limit", Limit) &&
      O.map("RestrictForCodeCompletion", Request.RestrictForCodeCompletion) &&
      O.map("ProximityPaths", Request.ProximityPaths) &&
      O.map("PreferredTypes", Request.PreferredTypes);
  if (OK && Limit <= std::numeric_limits<uint32_t>::max())
    Request.Limit = Limit;
  return OK;
}

llvm::json::Value toJSON(const FuzzyFindRequest &Request) {
  return llvm::json::Object{
      {"Query", Request.Query},
      {"Scopes", llvm::json::Array{Request.Scopes}},
      {"AnyScope", Request.AnyScope},
      {"Limit", Request.Limit},
      {"RestrictForCodeCompletion", Request.RestrictForCodeCompletion},
      {"ProximityPaths", llvm::json::Array{Request.ProximityPaths}},
      {"PreferredTypes", llvm::json::Array{Request.PreferredTypes}},
  };
}

bool SwapIndex::fuzzyFind(const FuzzyFindRequest &R,
                          llvm::function_ref<void(const Symbol &)> CB) const {
  return snapshot()->fuzzyFind(R, CB);
}
void SwapIndex::lookup(const LookupRequest &R,
                       llvm::function_ref<void(const Symbol &)> CB) const {
  return snapshot()->lookup(R, CB);
}
void SwapIndex::refs(const RefsRequest &R,
                     llvm::function_ref<void(const Ref &)> CB) const {
  return snapshot()->refs(R, CB);
}
size_t SwapIndex::estimateMemoryUsage() const {
  return snapshot()->estimateMemoryUsage();
}

} // namespace clangd
} // namespace clang
