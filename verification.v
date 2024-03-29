(* You may modify these imports, but you shouldn't need to. *)
Require Import List Arith Bool.
Import ListNotations.

(** * A5 *)

(********************************************************************
                                       
                                                 
               AAA            555555555555555555 
              A:::A           5::::::::::::::::5 
             A:::::A          5::::::::::::::::5 
            A:::::::A         5:::::555555555555 
           A:::::::::A        5:::::5            
          A:::::A:::::A       5:::::5            
         A:::::A A:::::A      5:::::5555555555   
        A:::::A   A:::::A     5:::::::::::::::5  
       A:::::A     A:::::A    555555555555:::::5 
      A:::::AAAAAAAAA:::::A               5:::::5
     A:::::::::::::::::::::A              5:::::5
    A:::::AAAAAAAAAAAAA:::::A 5555555     5:::::5
   A:::::A             A:::::A5::::::55555::::::5
  A:::::A               A:::::A55:::::::::::::55 
 A:::::A                 A:::::A 55:::::::::55   
AAAAAAA                   AAAAAAA  555555555     

*********************************************************************)

(**

Here is an OCaml interface for queues:
<<
(* ['a t] is a queue containing values of type ['a]. *)
type 'a t

(* [empty] is the empty queue *)
val empty : 'a t

(* [is_empty q] is whether [q] is empty *)
val is_empty : 'a t -> bool

(* [front q] is [Some x], where [x] the front element of [q],
 * or [None] if [q] is empty. *)
val front : 'a t -> 'a option

(* [enq x q] is the queue that is the same as [q], but with [x] 
 * enqueued (i.e., inserted) at the end. *)
val enq : 'a -> 'a t -> 'a t

(* [deq x q] is the queue that is the same as [q], but with its
 * front element dequeued (i.e., removed).  If [q] is empty, 
 * [deq q] is also empty. *)  
val deq : 'a t -> 'a t
>>

Note that the specification for [deq] differs from what we have given
before:  the [deq] of an empty list is the empty list; there are no
options or exceptions involved.

Here is an equational specification for that interface:
<<
(1) is_empty empty      = true
(2) is_empty (enq _ _ ) = false
(3) front empty         = None
(4) front (enq x q)     = Some x         if is_empty q = true
(5) front (enq _ q)     = front q        if is_empty q = false
(6) deq empty           = empty
(7) deq (enq _ q)       = empty          if is_empty q = true
(8) deq (enq x q)       = enq x (deq q)  if is_empty q = false
>>

Your task in the next two parts of this file is to implement the Coq equivalent
of that interface and prove that your implementation satisfies the equational
specification.  Actually, you will do this twice, with two different
representation types, as we studied back in Lab 7:

- _simple queues_, which represent a queue as a singly-linked list
  and have worst-case linear time performance.

- _two-list queues_, which represent a queue with two singly-linked
  lists, and have amortized constant time performance.

*)




(********************************************************************)
(** ** Part 1: Simple Queues *)
(********************************************************************)

Module SimpleQueue.

(** Your first task is to implement and verify simple queues.
    To get you started, we provide the following definitions for
    the representation type of a simple queue, and for the empty
    simple queue. *)

(** [queue A] is the type that represents a queue as a
    singly-linked list.  The list [[x1; x2; ...; xn]] represents
    the queue with [x1] at its front, then [x2], ..., and finally
    [xn] at its end.  The list [[]] represents the empty queue. *)
Definition queue (A : Type) := list A.

Definition empty {A : Type} : queue A := [].

(**
*** Implementation of simple queues.
Define [is_empty], [front], [enq], and [deq]. We have provided some starter code
below that type checks, but it defines those operations in trivial and incorrect
ways. _Hint:_ this isn't meant to be tricky; you just need to translate the code
you would naturally write in OCaml into Coq syntax.
*)

Definition is_empty {A : Type} (q : queue A) : bool :=
  match q with
  |[]=> true
  |_::_=> false
  end.

Definition front {A : Type} (q : queue A) : option A :=
  match q with
  |h::_=> Some h
  |[]=> None
  end.

Fixpoint enq {A : Type} (x : A) (q : queue A) : queue A :=
  match q with
  |[]=> x::[]
  |h::t=> h::(enq x t)
  end.

Definition deq {A : Type} (q : queue A) : queue A :=
  match q with
  |[]=> []
  |_::t=>t
  end.

(**
*** Verification of simple queues.
Prove that the equations in the queue specification hold. We have written
them for you, below, but instead of a proof we have written [Admitted].  That
tells Coq to accept the theorem as true (hence it will compile) even though
there is no proof.  You need to replace [Admitted] with [Proof. ...  Qed.]
_Hint:_ none of these proofs requires induction.
*)

Theorem eqn1 : forall (A : Type),
  is_empty (@empty A) = true.
  Proof.
    simpl.
    trivial.
  Qed.

Theorem eqn2 : forall (A : Type) (x : A) (q : queue A),
  is_empty (enq x q) = false.
  intros A x q.
  destruct q.
  all: unfold enq;unfold is_empty;trivial.
Qed.

Theorem eqn3 : forall (A : Type),
  front (@empty A) = None.
  Proof.
    simpl.
    trivial.
  Qed.
  
Theorem eqn4 : forall (A : Type) (x : A) (q : queue A),
  is_empty q = true -> front (enq x q) = Some x.
  
  Proof.
    intros A x q empty_true.
   destruct q.
   unfold enq.
   unfold front.
   trivial.
   discriminate.
  Qed.

Theorem eqn5 : forall (A : Type) (x : A) (q : queue A),
  is_empty q = false -> front (enq x q) = front q.
  
  Proof.
   intros A x q not_empty_q.
   destruct q.
    discriminate.
   all: unfold enq;unfold front;trivial.
  Qed.

Theorem eqn6 : forall (A : Type),
  deq (@empty A) = (@empty A).
   
  Proof.
    simpl.
    trivial.
  Qed.

Theorem eqn7 : forall (A : Type) (x : A) (q : queue A),
  is_empty q = true -> deq (enq x q) = empty.
  Proof.
    intros A x q empty_q.
    destruct q.
    unfold enq. unfold deq. trivial.
    discriminate.
  Qed.

Theorem eqn8 : forall (A : Type) (x : A) (q : queue A),
  is_empty q = false -> deq (enq x q) = enq x (deq q).
  Proof.
    intros A x q not_empty_q.
    destruct q.
    unfold enq. unfold deq. discriminate.
    unfold enq. unfold deq. trivial.
  Qed.

End SimpleQueue.

(********************************************************************)
(** ** Part 2: Two-list Queues *)
(********************************************************************)

Module TwoListQueue.

(** Your second task is to implement and verify two-list queues.
    To get you started, we provide the following definitions for
    the representation type of a two-list queue, and for the empty
    two-list queue. *)

(** [queue A] is the type that represents a queue as a pair of two
    singly-linked lists.  The pair [(f,b)] represents the same
    queue as does the simple queue [f ++ rev b].  The list [f] is
    the front of the queue, and the list [b] is the back of the
    queue stored in reversed order.

    _Representation invariant:_  if [f] is [nil] then [b] is [nil].

    The syntax [% type] in this definition tells Coq to treat the
    [*] symbol as the pair constructor rather than multiplication.
    You shouldn't need to use that syntax anywhere in your solution. *)
Definition queue (A : Type) := (list A * list A) % type.

(** [rep_ok q] holds iff [q] satisfies its RI as stated above *)
Definition rep_ok {A : Type} (q : queue A) : Prop :=
  match q with
  | (f,b) => f = [] -> b = []
  end.

Definition empty {A : Type} : queue A := ([],[]).

(**
*** Implementation of two-list queues.
Define [is_empty], [front], [enq], and [deq]. We have provided some starter code
below that type checks, but it defines those operations in trivial and incorrect
ways. _Hint:_ this isn't meant to be tricky; you just need to translate the code
you would naturally write in OCaml into Coq syntax.  You will need to define
one new function as part of that.
*)

Definition is_empty {A : Type} (q : queue A) : bool :=
  match q with
  |([],[])=>true
  |(_,_)=>false
  end.

Definition front {A : Type} (q : queue A) : option A :=
  match q with
  |([],_)=> None
  |(h::_,_)=>Some h
  end.

Definition norm {A : Type} (q : queue A) : queue A :=
  match q with
  |([],R)=>(rev R,[])
  | _ => q
  end.

Definition enq {A : Type} (x : A) (q : queue A) : queue A :=
  match q with
  |(L,R)=>norm (L, x::R)
  end.

Definition deq {A : Type} (q : queue A) : queue A :=
  match q with
  |(_::t,R)=> norm(t,R)
  |_ => q
  end.

(**
*** Verification of two-list queues.
Next you need to prove that the equations in the queue specification hold.
The statements of those equations below now include as a precondition
that the RI holds of any input queues.
_Hint:_ none of these proofs requires induction, but they will be
harder and longer than the simple queue proofs.
*)

Theorem eqn1 : forall (A : Type),
  is_empty (@empty A) = true.
  Proof.
    simpl. trivial.
  Qed.

Lemma eqn2_helper : forall (A : Type) (x : A) (R : list A),
  R = [] -> is_empty (enq x ([], R)) = false.
Proof.
  intros A x R R_empty. rewrite R_empty. 
  unfold enq. unfold is_empty. simpl. trivial.
Qed.

Theorem eqn2 : forall (A : Type) (x : A) (q : queue A),
  rep_ok q -> is_empty (enq x q) = false.
  Proof.
    intros A x q rep_gucci.
    destruct q. destruct l.
    - rewrite eqn2_helper. trivial. rewrite rep_gucci. trivial. trivial.
    - unfold enq. simpl. trivial. 
  Qed.

Theorem eqn3 : forall (A : Type),
  front (@empty A) = None.
  Proof.
    simpl. trivial.
  Qed.

Theorem eqn4 : forall (A : Type) (x : A) (q : queue A),
  rep_ok q -> is_empty q = true -> front (enq x q) = Some x.
  Proof.
    intros A x q rep_gucci q_empty.
    destruct q as [[ |h1 t1 ][ | h2 t2]]. 
    - simpl. trivial.
    - rewrite rep_gucci. trivial. trivial.
    - discriminate.
    - discriminate. 
  Qed.

Lemma fals : forall (A : Type) (lst2 : list A) ,
  rep_ok ([],lst2) /\ lst2 <> [] -> False.
intros A lst2 rep. destruct rep as [ok lst]. Check ok. auto.
Qed.

Print fals.

Lemma fal' : forall (A : Type) (h2 : A),
  ([h2] = []) ->  False.
Proof.
  intros A h2. intros ass. discriminate.
Qed. 

Lemma fal'' : forall (A : Type) (h2 : A) (t2 : list A),
  h2::t2 = [] -> False.
Proof.
  intros A h2 t2 ass. discriminate.
Qed. 

Lemma repp : forall (A :Type) (h2 : A) (t2: list A),
  rep_ok ([],h2::t2)-> False.
Proof.
  intros A h2 t2 ass.
  simpl in ass. destruct t2 as [|em nem]. 
  apply fal' in ass. 
  assumption. trivial. simpl in ass. apply fal'' in ass.
  assumption. trivial.
Qed.

Theorem eqn5 : forall (A : Type) (x : A) (q : queue A),
  rep_ok q -> is_empty q = false -> front (enq x q) = front q.
  intros A x q repok notEm. destruct q as [[|h1 t1] [|h2 t2]]. 
  simpl. discriminate.
  - simpl in repok. apply fal'' in repok. contradiction.
  trivial.
  - auto.
  - auto.
Qed.

Theorem eqn6 : forall (A : Type),
  deq (@empty A) = @empty A.
  Proof.
    simpl. trivial.
  Qed.

Theorem eqn7 : forall (A : Type) (x : A) (q : queue A),
  rep_ok q -> is_empty q = true -> deq (enq x q) = empty.
  Proof.
    intros A x q rep_gucci empty_q.
    destruct q as [ [|h1 t1] [|h2 t2] ].  
    - simpl. trivial.
    - rewrite rep_gucci. simpl. trivial. trivial.
    - discriminate.
    - discriminate.
  Qed.

(**
It turns out that two-list queues actually do not satisfy [eqn8]! To show that,
find a counterexample:  values for [x] and [q] that cause [eqn8] to be invalid.
Plug in your values for [x] and [q] below, then prove the three theorems
[counter1], [counter2], and [counter3].  _Hint_: if you choose your values well,
the proofs should be easy; each one should need only about one tactic.
*)

Module CounterEx.

Definition x : nat := 666.
(* change [0] to a value of your choice *)
Definition q : (list nat * list nat) := (3::[],5::4::[]).
(* change [empty] to a value of your choice *)

Theorem counter1 : rep_ok q.
Proof.
  discriminate.
Qed.

Theorem counter2 : is_empty q = false.
Proof.
  simpl. trivial.
Qed.

Theorem counter3 : deq (enq x q) <> enq x (deq q).
Proof.
  simpl. discriminate.
Qed.

End CounterEx.

(**
Two-list queues do satisfy a relaxed version of [eqn8], though,
where instead of requiring [deq (enq x q)] and [enq x (deq q)]
to be _equal_, we only require them to be _equivalent_ after being
converted to simple queues.  The following definition implements
that idea of equivalence:
*)

Definition equiv {A:Type} (q1 q2 : queue A) : Prop :=
  match (q1, q2) with
  | ((f1,b1),(f2,b2)) => f1 ++ rev b1 = f2 ++ rev b2
  end.

Hint Unfold equiv.
(* The command above gives a hint to the [auto] tactic to try unfolding
   [equiv] as part of its proof search.  This will help you in the
   next proof. *)

(**
Now prove that the following relaxed form of [eqn8] holds.  _Hint:_
this is probably the hardest proof in the assignment.  Don't hesitate
to manage the complexity of the proof by stating and proving helper lemmas.
*)

Lemma fals1 : forall (A : Type) (lst2 : list A) ,
rep_ok ([],lst2) /\ lst2 <> [] -> False.
intros A lst2 rep. destruct rep as [ok lst]. Check ok. auto.
Qed.

Print fals1.

Lemma fal1' : forall (A : Type) (h2 : A),
([h2] = []) ->  False.
Proof.
intros A h2. intros ass. discriminate.
Qed. 


Lemma fal1'' : forall (A : Type) (h2 : A) (t2 : list A),
h2::t2 = [] -> False.
Proof.
intros A h2 t2 ass. discriminate.
Qed. 

Lemma repp1 : forall (A :Type) (h2 : A) (t2: list A),
rep_ok ([],h2::t2)-> False.
Proof.
intros A h2 t2 ass.
simpl in ass. destruct t2 as [|em nem]. 
apply fal1' in ass. 
assumption. trivial. simpl in ass. apply fal1'' in ass.
assumption. trivial.
Qed.

(*)
Lemma helppp : forall (A : Type) (x h1 h2 : A) (t2 : list A),
equiv (deq (enq x ([h1], h2 :: t2))) (enq x (deq ([h1], h2 :: t2))).
Proof.
  intros A x h1 h2  t2. simpl.
*)

(*)
Lemma hii : forall (A : Type) (x h1 h2 : A) (t2 : list A),
(enq x (deq ([h1], h2 :: t2))) = ((rev t2 ++ [h2])++[x],[]).
Proof.
  intros A x h1 h2 t2. simpl. destruct t2 as [|em mem].
  - simpl. auto. 
Qed.
*)
(*)
Lemma helppp : forall (A : Type) (t2 : list A),
  rev
*)

(*)
Lemma nonem : forall (A : Type) (em' h2 : A) (mem' : list A),
  (rev mem' ++ [em']) ++[h2]<>  [].
Proof.
  intros A em' h2 mem'.
  destruct mem' as [| a b]. 
*)

Theorem eqn8_equiv : forall (A : Type) (x : A) (q : queue A),
  rep_ok q -> is_empty q = false ->
  equiv (deq (enq x q)) (enq x (deq q)).
Proof.
  intros A x q rep notem.
  destruct q as [[| h1 t1] [| h2 t2]].
  - discriminate.
  - apply repp1 in rep. contradiction.
  - destruct t1 as [|em mem]; simpl; auto.
  - destruct t1 as [|em mem];unfold equiv; destruct t2 as [| em' mem'];
    simpl; trivial.
    destruct (rev mem' ++ [em']);simpl;auto.
      replace (((l ++ [h2]) ++ [x]) ++ []) with ((l ++ [h2]) ++ [x]).
      auto. rewrite <-app_nil_end. trivial. 
Qed.

(**
Finally, verify that [empty] satisfies the RI, and that [enq] and [deq] both
preserve the RI.  _Hint:_ the last proof requires induction.
*)

Theorem rep_ok_empty : forall (A : Type),
  rep_ok (@empty A).
  Proof.
    intros A. simpl. trivial.

  Qed.


Theorem rep_ok_enq : forall (A : Type) (q : queue A),
  rep_ok q -> forall (x : A), rep_ok (enq x q).
  Proof.
    intros A q rep_gucci_q x.
    destruct q as [ [|h1 t1] [|h2 t2] ].
    - simpl. discriminate.
    - simpl. trivial. 
    - simpl. discriminate.
    - simpl. discriminate.
  Qed.


Lemma rep_ok_deq_helper: forall (A : Type) (L : list A),
  rep_ok (L,[]) -> rep_ok (deq (L,[])).
  Proof.
    intros A L rep_gucci.
    destruct L as [|h t] .
    - simpl. trivial.
    - simpl. destruct t. simpl. trivial. simpl. discriminate.  
  Qed.

Theorem rep_ok_deq: forall (A : Type) (q : queue A),
  rep_ok q -> rep_ok (deq q).
  Proof.
    intros A q rep_gucci.
    destruct q as [ [|h1 t1] [|h2 t2] ].
    - simpl. trivial.
    - simpl. trivial.
    - simpl. destruct t1. simpl . trivial. simpl.  discriminate. 
    - simpl. destruct t1. simpl. auto. simpl. discriminate. 
  Qed.


End TwoListQueue.

(********************************************************************)
(** ** Part 3: Logic *)
(********************************************************************)

Module Logic.

(**
Prove each of the following theorems.  You may _not_ use the [tauto]
or [auto] tactic in your proofs.
*)

Theorem logic1 : forall P Q R S T: Prop,
  ((P /\ Q) /\ R) -> (S /\ T) -> (Q /\ S).
Proof.
  intros P Q R S T PandQandR SandT.
  split.
  - destruct PandQandR as [PandQ evR].
    destruct PandQ as [evP evQ].
    assumption.
  - destruct SandT as [evS evT].
    assumption.
Qed.

Theorem logic2 : forall P Q R S : Prop,
  (P -> Q) -> (R -> S) -> (P \/ R) -> (Q \/ S).
Proof.
  intros P Q R S PimpQ RimpS PorR.
  destruct PorR as [evP | evR]. 
  left. apply PimpQ. assumption.
  right. apply RimpS. assumption.
Qed.

Theorem logic3 : forall P Q : Prop,
  (P -> Q) -> (((P /\ Q) -> P) /\ (P -> (P /\ Q))).
Proof.
  intros P Q PimpQ.
  split.
  - intros PandQ. destruct PandQ as [evP evQ]. assumption.
  - intros evP. split. assumption. apply PimpQ. assumption.
Qed. 

Theorem logic4 : forall P Q : Prop,
  (P -> Q) -> (~~P -> ~~Q).
Proof.
  intros P Q PimpQ.
  unfold not.
  intros nnP nQ.
  apply nnP.
  intros evP. apply nQ. apply PimpQ. assumption.
Qed.

End Logic.

(********************************************************************)
(** ** Part 4: Induction *)
(********************************************************************)

Module Induction.

(**
Here is an OCaml function:
<<
let rec sumsq_to n =
  if n = 0 then 0
  else n*n + sumsq_to (n-1)
>>

Prove that
<<
  sumsq_to n  =  n * (n+1) * (2*n + 1) / 6
>>

First, prove it mathematically (i.e., not in Coq), by completing
the following template.

-----------------------------------------------------------------
Theorem:  sumsq_to n = n * (n+1) * (2*n + 1) / 6.

Proof:  by induction on n.

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


Let P(n) be the statement "sumsq_to n = n * (n+1) * (2*n + 1) / 6".
In addition, we'll use the notation e1 {e2,e3} to represent "substitute 
e3 for e2 in the expression e1" (this is analogous to let e2 = e3 in e1).

Base case P(0): 
  (n * (n+1) * (2*n + 1) / 6) {n,0} = 0 * (0+1) * (2*0 + 1)/6 = 0
  sunsq_to 0 = 0 (this is true since it matches the first case of the 
  definition of sumsq_to n, hence BY DEFINITION).
  Hence P(0) holds.

Inductive Hypothesis (IH): Assume P(k).

Inductive case: Show P(k+1).
  sumsq_to (k+1) = (k+1)*(k+1) + sumsq_to (k)                  (BY DEFINITION)
                 = (k+1)*(k+1) + k*(k+1)*(2*k+1)/6             (BY IH)
                 = (k+1)*((k+1)+(k*(2*k+1)/6))                 (BY ALGEBRA)
                 = (k+1)*(6*(k+1)+k*(2*k+1))/6                 (THE REST IS)
                 = (k+1)*(6*(k+2-1)+(k+2-2)*(2*k+1))/6         (JUST ALGEBRA)
                 = (k+1)*((k+2)*(6+2*k+1)-6-2*(2*k+1)/6
                 = (k+1)*((k+2)*(2k+7)-4*k-8)/6          
                 = (k+1)*((k+2)*(2*k+7)-4(k+2)/6
                 = (k+1)*(k+2)*(2*k+3)/6
                 = (k+1)*(k+2)*(2*(k+1)+1)/ 6
QED.

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

FILL IN your proof here.                                  [Proof above] 
You must state the property P, the base case,
the inductive case, and the inductive hypothesis, and justify the
reasoning you use in each proof step.  "By algebra" is an acceptable
justification for collecting terms, adding, multiplying, etc.  If you
need to judiciously break the 80-column limit, that's okay.

QED.
-----------------------------------------------------------------

Second, prove it in Coq, by completing the following code.
*)

(** [sumsq_to n] is [0*0 + 1*1 + ... + n*n]. *)
Fixpoint sumsq_to (n:nat) : nat :=
  match n with
  | 0 => 0
  | S k => (k+1)*(k+1) + sumsq_to (k)
  end.

(*  *)
Lemma sum_helper : forall n,
  sumsq_to (S n) = (n+1)*(n+1) + sumsq_to n.
Proof.
  intros n. simpl. ring.
Qed.

Lemma distr : forall l m n,
  l * (n + sumsq_to m) = l * n + l*sumsq_to m.
Proof.
  intros l m n. 
  induction l as [ | a IH]. 
  trivial. ring. 
Qed.

Theorem sumsq : forall n,
  6 * sumsq_to n = n * (n+1) * (2*n+1).
Proof.
  intros n.
  induction n as [ |k IH].
  - trivial.
  - rewrite sum_helper.
    rewrite -> distr. 
    rewrite -> IH. 
    ring. 
Qed.

End Induction.

(********************************************************************)
(** THE END *)
(********************************************************************)