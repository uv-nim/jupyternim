import strutils, times, random, hmac, nimSHA2, md5, zmq

template debug*(str: varargs[string, `$`]) =
  when not defined(release):
    let inst = instantiationinfo()
    echo "[" & $inst.filename & ":" & $inst.line & "] ", str.join(" ")
  else:
    discard

const validx = ['A', 'B', 'C', 'D', 'E', 'F', 
                '0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
const validy = ['8', '9', '0', 'B']

proc genUUID*(nb, upper: bool = true): string =
  ## Generate a uuid version 4.
  ## If ``nb`` is false, the uuid is compatible with IPython console.
  result = if nb: "xxxxxxxxxxxx4xxxyxxxxxxxxxxxxxxx" else: "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
  for c in result.mitems:
    if c == 'y': c = sample(validy)
    elif c == 'x': c = sample(validx)
  if not upper: result = result.toLowerAscii

proc sign*(msg: string, key: string): string =
  ##Sign a message with a secure signature.
  result = hmac.hmac_sha256(key, msg).hex.toLowerAscii

proc getISOstr*(): string = getDateStr()&'T'&getClockStr()

proc flatten*(flags: openArray[string]): string =
  result = " "
  for f in flags: result.add(f&" ")

proc send_multipart*(c: TConnection, msglist: openArray[string]) =
  ## sends a message over the connection as multipart.
  for i, msg in msglist:
    let flag = if i != msglist.len-1: SNDMORE else: NOFLAGS
    c.send(msg,flag)

proc recv_multipart*(c: TConnection): seq[string] =
  result = @[]
  var hasMore = true
  while hasMore:
    #debug "HASMORE: ", hasMore
    let rc = c.s.receive()
    if rc != "": 
      result &= rc
    if getsockopt[int](c.s, RCVMORE) == 0:
      # if RCVMORE == 0, this is either a single message or 
      # we reached the last frame
      hasMore = false
  # debug "RECV MULTIPART LEN: ", result.len

proc filter*[T](seq1: openarray[T], 
                pred: proc(item: T): bool {.closure.}): seq[T] {.inline.} =
  ## Returns a new sequence with all the items that fulfilled the predicate.
  ## Copied from sequtils, modified to work with openarray
  result = newSeq[T]()
  for i in 0..<seq1.len:
    if pred(seq1[i]):
      result.add(seq1[i])